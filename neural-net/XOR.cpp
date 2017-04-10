#include <iostream>
using namespace std;

int XOR_Network(int input1, int input2) {
  // Internal Units
  double thresholds = 0.01;
  int inter_uni1 =  1 * input1 + -1 * input2 >= thresholds ? 1 : 0;
  int inter_uni2 = -1 * input1 +  1 * input2 >= thresholds ? 1 : 0;
  
  // Output Unit
  int output = inter_uni1 + inter_uni2;
  
  return output;
}

int main(void)
{
  cout << XOR_Network(0, 0) << endl;
  cout << XOR_Network(0, 1) << endl;
  cout << XOR_Network(1, 0) << endl;
  cout << XOR_Network(1, 1) << endl;
}
