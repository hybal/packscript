module test::parser;
import parser;

fn void! test_arithmetic() @test
{
   assert("1 + 1".eval_str()! == 2); 
   assert("-1 - 1".eval_str()! == -2);
   assert("0b1 + 0b1".eval_str()! == 2);
}
