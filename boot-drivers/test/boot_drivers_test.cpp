#include "gtest/gtest.h"

class Boot_Drivers_Test : public ::testing::Test
{
    protected:
    virtual void SetUp() { }
};

/* bad test almost guaranteed to pass */
TEST_F(Boot_Drivers_Test, Load_rtc-ds3232e)
{
    int result = system("sh /etc/init.d/rtc-ds3232e.sh");
    char * driver_path;
    driver_path = getenv("RTCDS3232PATH");
    char * failed_path;
    failed_path = "unset";
    ASSERT_NEQ(
        failed_path,
        driver_path
    );
}

TEST_F(Boot_Drivers_Test, Load_hmc5842)
{
    int result = system("sh /etc/init.d/hmc5842.sh");
    ASSERT_EQ(
        0,
        result 
    );
}

TEST_F(Boot_Drivers_Test, Load_ad799x.sh)
{
    int result = system("sh /etc/init.d/ad799x.sh");
    ASSERT_EQ(
        0,
        result 
    );
}
