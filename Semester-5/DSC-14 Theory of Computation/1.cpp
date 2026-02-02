
#include<iostream>
#include<string>
using namespace std;
void q0(string w , int i);
void q1(string w , int i);
void q2(string w , int i);
void q3(string w , int i);
int main()
{
	string w;
	cout << "enter the string (1/0) : ";
	cin >> w;
	q0(w, 0);
	return 0;
}
void q0(string w , int i)
{
	if (i == w.length())
		cout << "String rejected";
	if (w[i] == '0')
		q0(w, i + 1);
	else if (w[i] == '1')
		q1 (w, i + 1);
}
void q1(string w , int i)
{
	if (i == w.length())
		cout << "String rejected";
	if (w[i] == '0')
		q0(w, i + 1);
	else if (w[i] == '1')
		q2 (w, i + 1);
}
void q2(string w , int i)
{
	if (i == w.length())
		cout << "String rejected";
	if (w[i] == '0')
		q0(w, i + 1);
	else if (w[i] == '1')
		q3 (w, i + 1);
}
void q3(string w , int i)
{
	if (i == w.length())
		cout << "String accepted";
	else 
		q3 (w, i + 1);
}