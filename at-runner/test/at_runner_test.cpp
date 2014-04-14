#include "gtest/gtest.h"
#include "../inc/schedule-command.h"

class At_Runner_Test : public ::testing::Test
{
    protected:
    virtual void SetUp() { }

    const static int fdin = 1; // fake file descriptor to simulate HE100   
    size_t z; // assert loop index
};

/* bad test almost guaranteed to pass */
TEST_F(At_Runner_Test, AddJob)
{
    //int result = addJob("201503212330","/usr/bin/touch testfile");
    char date_time[13] = "201404082328";
    char task[48] = "/bin/echo $(date --iso) >> /media/Data/test.log";
    int result = addJob(date_time,task);
    ASSERT_EQ(
        0,
        result 
    );
}

/* Check array */ /*
TEST_F(At_Runner_Test, CompareArrays)
{
    for (z=0; z<37; z++) {
        ASSERT_EQ(
            expected[z],
            result[z]
        );
    }
}
*/

// test pipe operations

// test log operations
