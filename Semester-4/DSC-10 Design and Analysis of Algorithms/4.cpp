// Write a program to sort the elements of an array using Quick Sort (The program should report the number of comparisons).

#include <iostream>
using namespace std;

void quickSort(int arr[], int low, int high, int &comparisons) {
    if (low < high) {
        int pivot = arr[high];
        int i = low - 1; 

        for (int j = low; j < high; j++) {
            comparisons++; 
            if (arr[j] < pivot) {
                i++;
                swap(arr[i], arr[j]);
            }
        }
        swap(arr[i + 1], arr[high]); 
        int pi = i + 1; 

        quickSort(arr, low, pi - 1, comparisons); 
        quickSort(arr, pi + 1, high, comparisons); 
    }
}

int main() {
    int arr[] = {10, 7, 8, 9, 1, 5};
    int n = sizeof(arr) / sizeof(arr[0]);
    int comparisons = 0;

    quickSort(arr, 0, n - 1, comparisons);

    cout << "Sorted array: ";
    for (int i = 0; i < n; i++)
        cout << arr[i] << " ";
    cout << endl;
    cout << "Number of comparisons: " << comparisons << endl;

    return 0;
}
// Output:
// Sorted array: 1 5 7 8 9 10
// Number of comparisons: 11
// Time Complexity: O(n log n) on average, O(n^2) in the worst case (when the array is already sorted or reverse sorted)
// Space Complexity: O(log n) for the recursion stack
// Note: The number of comparisons may vary based on the input array and the pivot selection strategy.
// The above implementation uses the last element as the pivot. Other strategies include using the first element, random element, or median of three.