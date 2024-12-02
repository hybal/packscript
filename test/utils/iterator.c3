module test::utils::iterator @test;
import utils::iterator;
def DefaultIter = iterator::DefaultIterator(<int>);

fn void test_default()
{
    int[] test_data = {1, 2, 3, 4};
    DefaultIter iter = test_data.iterator();
    assert(iter.has_next());
    assert(@ok(iter.peek()));
    assert(iter.next()!! == 1);
    assert(iter.get()!! == 1);
    assert(@ok(iter.peek_back()) == false);
    assert(iter.next()!! == 2);
    assert(@ok(iter.peek_back()));
    assert(iter.back()!! == 1);
    iter.next()!!;
    iter.next()!!;
    iter.next()!!;
    iter.next()!!;
    assert(@ok(iter.next()) == false);
}
