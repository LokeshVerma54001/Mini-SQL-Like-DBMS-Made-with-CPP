#include<iostream>
#include<string>
using namespace std;

int main(){
    string query;
    cout << "MiniSql >";
    while (getline(cin, query))
    {  
        if(query == "exit") break;
        cout << "You entered: " << query << endl;
        cout << "MiniSql >";
    }
    return 0; 
}