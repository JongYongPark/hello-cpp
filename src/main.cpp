#include <iostream>
#include <vector>
#include <string>
#include <random>

#include <stdio.h>
#include <stdlib.h>


using namespace std;

////////////////////////////////////////////////
void forward_null(void)
{
	char* p = 0;
	*p = 'a';
}

void forward_null1(void)
{
    char* p = 0;
    *p = 'a';
}

void forward_null2(void)
{
    char* p = 0;
    *p = 'a';
}

void reverse_null(char* input)
{
	*input = 12;
	if (input == NULL)
		return;
}

void resource_leak(void)
{
	char *p = (char*) malloc(4);
	p[0] = 12;
}

void resource_leak_2(void)
{
	char *p = (char*) malloc(4);
	char *q = (char*) malloc(12);
	if (!p || !q)
		return;
}

void use_after_free(void)
{
	char *p = (char*) malloc(4);
	free(p);
	*p = 'a';
}

struct bigger_than_ptr { int a; int b; int c; int d; };

void size_check(void)
{
	struct bigger_than_ptr *p;
	p = (bigger_than_ptr*) malloc(sizeof(struct bigger_than_ptr *));
}

int some_func(void){ return 1;}

void dead_code(void)
{
	int x = some_func();
	if (x) {
		if (!x) {
			x++;
			return;
		}
	}
}

int my_read(int, char*, int){
	return 1;
}

void negative_returns(void)
{
	char buf[10];
	int j = my_read(1, buf, 8);
	buf[j] = '\0';
}

void reverse_negative(void)
{
	int j = some_func();
	char buf[10];
	buf[j] = '\0';
	if (j < 0)
		return;
}

void uninit(void)
{
	char* p;
	*p = 'a';
}

void overrun_static(void)
{
	char buf[10];
	int i;
	for (i = 0; i <= 10; i++)
		buf[i] = '\0';
}

#define NO_MEM -1
#define OK 0
#define OTHER_ERROR -2

bool some_other_function(void){ return true; } 
bool yet_another_function(void){ return true; }
bool do_some_things(char *){ return true; }

int paths() {
	char *p = (char*) malloc(12);

	if (!p)
		return NO_MEM;

	if (!some_other_function()) {
		free(p);
		return OTHER_ERROR;
	}

	if (!yet_another_function()) {
		return OTHER_ERROR;
	}

	do_some_things(p);

	free(p);
	return OK;
} 


//////////////////////////

#include <iostream>
#include <string>
#include <cstring>  // strcpy
#include <stdio.h>  // sprintf_s
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <assert.h>

using namespace std;

int call_test12345() {
	// change here for test
	return 1;
}

int false_positive()
{
	// coverity[no_escape : FALSE]
	while(1);
}

int suppress()
{
	// coverity[no_escape : SUPPRESS]
	while(1);
}

int intentional()
{
	// coverity[no_escape]
	while(1);
}


int infinite_loop_test1()
{
	while (1); // new from desktop
	return 1;
}
int callee(int i){
	int j=1;
	j--;
	return i/j;
}

// auto change function name 
void new_defects_240830_035044()
{
	while(1);//here
	callee(10);
	return;
    //return "hello";
} 

int for_desktop(){
	while(1);
}

////////////////////////
// misra annotation and progma 
///////////////////
bool random_bool(){
	// https://velog.io/@t1won/C-11-%EB%82%9C%EC%88%98-%EC%83%9D%EC%84%B1-random-%EB%9D%BC%EC%9D%B4%EB%B8%8C%EB%9F%AC%EB%A6%AC
    // 시드값을 얻기 위한 random_device 생성.
    std::random_device rd;

    // random_device 를 통해 난수 생성 엔진을 초기화 한다.
    std::mt19937 gen(rd());

    // 0 부터 99 까지 균등하게 나타나는 난수열을 생성하기 위해 균등 분포 정의.
    std::uniform_int_distribution<int> dis(0, 99);

    for (int i = 0; i < 5; i++)
    {
        std::cout << "Ramdom Num : " << dis(gen) << std::endl;
    }

	int rand = dis(gen);
	rand = rand % 100;

	if( rand % 2 == 0 ) return true;
	else
		return false;
}

bool compliant_and ()
{
	bool const b1 = random_bool();
	bool const b2 = random_bool();

	return b1 && b2;
}

// coverity[misra_cpp_2008_rule_7_3_1_violation:FALSE]
bool compliant_and__coverity_annotation()
{
	bool const b1 = random_bool();
	bool const b2 = random_bool();

	return b1 && b2;
}

#pragma coverity compliance deviate "MISRA C++-2008 Rule 7-3-1" "Test"
bool compliant_and__pragma_drective ()
{
	bool const b1 = random_bool();
	bool const b2 = random_bool();

	return b1 && b2;
}

bool compliant_or ()
{
	bool const b1 = random_bool();
	// coverity[misra_cpp_2008_rule_0_1_6_violation]
	bool const b2 = random_bool();
	return b1 || b2; // Rule 0-1-6 False Positive
}


void incompatible_test()
{
   char ca[123] = "hello";
   memcpy( &ca[6],"world",5);
}


int main()
{
    vector<string> msg {"Hello", "C++", "World", "from", "VS Code", "and the C++ extension!"};

    for (const string& word : msg)
    {
        cout << word << " ";
    }
    cout << endl;
}
