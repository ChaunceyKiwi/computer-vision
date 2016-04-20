#include <iostream>
using namespace std;

/*  Doing logical operation with weight
    when offset = -1, do 'or' operation
    when offset = -2, do 'and' operation */

int hardlim(int x1,int x2,int offset){
  if(x1+x2+offset >= 0) return 1;
  else return 0;
}


//
int main(void)
{
  // Input layer
  int a0[4] = {0,1,0,1};
  int b0[4] = {1,1,0,0};

  // Hidden layer
  int a1[4];
  int b1[4];
  for(int i = 0;i < 4;i++){
    a1[i] = hardlim(a0[i],1 - b0[i],-2);
    b1[i] = hardlim(1 - a0[i],b0[i],-2);
  }

  //output layer
  int output[4];
  for(int i = 0;i < 4;i++){
    output[i] = hardlim(a1[i],b1[i],-1);
    cout<<output[i]<<" ";
  }

  cout<<endl;
}
