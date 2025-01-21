#include <linux/kernel.h>

asmlinkage long sys_greet(void)
{
	int team_no = 35;
	printk("Greeting from kernel and team %d\n", team_no);
	return 0;
}
