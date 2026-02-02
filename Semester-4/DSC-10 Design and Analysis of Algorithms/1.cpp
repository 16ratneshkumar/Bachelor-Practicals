// Write a program to sort the elements of an array using Insertion Sort (The program should report the number of comparisons).

#include <iostream>
using namespace std;

void insertionSort(int arr[], int n, int &comparisons){
    comparisons = 0;
    for (int i = 1; i < n; i++) {
        int key = arr[i];
        int j = i - 1;
        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];
            j--;
            comparisons++;
        }
        arr[j + 1] = key;
        if (j >= 0) comparisons++;
    }
}

int main() {
    int arr[] = {12, 11, 13, 5, 6};
    int n = sizeof(arr) / sizeof(arr[0]);
    
    int comparisons = 0;
    insertionSort(arr, n, comparisons);
    
    cout << "Sorted array: ";
    for (int i = 0; i < n; i++) {
        cout << arr[i] << " ";
    }
    cout << endl;
    
    cout << "Number of comparisons: " << comparisons << endl;
    
    return 0;
}

//Output:
// Sorted array: 5 6 11 12 13
// Number of comparisons: 9
// Time Complexity: O(n^2) in the worst case and O(n) in the best case (when the array is already sorted).
// Space Complexity: O(1) as it sorts the array in place.
