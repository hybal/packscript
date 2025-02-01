use macros::*;
use petgraph::graph::NodeIndex;
use mlua::prelude::*;
use petgraph::graph::DiGraph;
use std::collections::HashMap;
use std::collections::HashSet;
use petgraph::algo::toposort;
use std::sync::{Arc, Mutex};
use rayon::prelude::*;


struct LuaGraph {
    graph: DiGraph<mlua::Table, ()>,
    names: HashMap<String, NodeIndex>
}

impl LuaGraph {
    fn propagate_update(self: &Self, node: NodeIndex, updated_nodes: &mut HashSet<NodeIndex>) -> LuaResult<()> {
        if !updated_nodes.contains(&node) {
            updated_nodes.insert(node);
            if self.graph[node].get::<bool>("is_dirty")? {
                if let LuaValue::Function(func) = self.graph[node].get::<mlua::Value>("func")? {
                    func.call::<()>(())?;
                }
                self.graph[node].set("is_dirty", false)?;
                let neighbors = self.graph.neighbors(node);
                for neighbor in neighbors {
                    self.propagate_update(neighbor, updated_nodes)?;
                }
            }
        }
        Ok(())
    }
    fn exec_parallel_updates(&mut self) -> LuaResult<()>{
        let updated_nodes = Arc::new(Mutex::new(HashSet::new()));
        let sorted_nodes = toposort(&self.graph, None).unwrap();
        sorted_nodes.into_par_iter().for_each(|node| {
            let mut updated_nodes = updated_nodes.lock().unwrap();
            self.propagate_update(node, &mut updated_nodes).unwrap();
            
        });
        Ok(())
    }
}

impl mlua::UserData for LuaGraph {
    fn add_methods<M: mlua::UserDataMethods<Self>>(methods: &mut M) {
        methods.add_method_mut("add_dependency", |_, this, (a,b): (String, String)| {
            let node_a = this.names.get(&a).ok_or_else(|| LuaError::RuntimeError(format!("Node '{}' not found", a)))?;
            let node_b = this.names.get(&b).ok_or_else(|| LuaError::RuntimeError(format!("Node '{}' not found", b)))?;
            this.graph.add_edge(*node_a, *node_b, ());
            Ok(())
        });
        methods.add_method_mut("add_node", |lua, this, (name, func): (String, mlua::Function)| {
            let node_table = lua.create_table()?;
            node_table.set("is_dirty", true)?;
            node_table.set("func", func)?;
            let node = this.graph.add_node(node_table);
            this.names.insert(name, node);
            Ok(())
        });
        methods.add_method("get_node", |_, this, name: String| {
            let node = this.names.get(&name).ok_or_else(|| LuaError::RuntimeError(format!("Node '{}' not found", name)))?;
            Ok(this.graph[*node].clone())
        });

        methods.add_method_mut("exec", |_, this, _: ()| {
            this.exec_parallel_updates()?;
            Ok(())
        });

        methods.add_method_mut("mark_dirty", |_, this, name: String| {
            let  node = this.names.get_mut(&name)
                .ok_or_else(|| LuaError::RuntimeError(format!("Node '{}' not found", name)))?;
            this.graph[*node].set("is_dirty", true)?;
            Ok(())
        });
    }
}

#[registry]
fn register(lua: &Lua) -> LuaResult<()> {
    lua.globals().set("buildgraph", LuaGraph { graph: DiGraph::new(), names: HashMap::new() })?;
    Ok(())
}
