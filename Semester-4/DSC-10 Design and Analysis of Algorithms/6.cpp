// Write a program to sort the elements of an array using Count Sort.

#include <iostream>
using namespace std;

void countSort(int arr[], int n) {
    int max = arr[0];
    for (int i = 1; i < n; i++) {
        if (arr[i] > max) {
            max = arr[i];
        }
    }

    int count[max + 1];
    for (int i = 0; i < max + 1; i++) {
        count[i] = 0;
    }

    for (int i = 0; i < n; i++) {
        count[arr[i]]++;
    }

    int j = 0;
    for (int i = 0; i < max + 1; i++) {
        while (count[i] > 0) {
            arr[j] = i;
            j++;
            count[i]--;
        }
    }
}

int main() {
    int arr[] = {4, 2, 2, 8, 3, 3, 1};
    int n = sizeof(arr) / sizeof(arr[0]);

    countSort(arr, n);

    cout << "Sorted array: ";
    for (int i = 0; i < n; i++) {
        cout << arr[i] << " ";
    }
    cout << endl;

    return 0;
}
// Output:
// Sorted array: 1 2 2 3 3 4 8
// Time Complexity: O(n + k), where n is the number of elements in the array and k is the range of the input (maxElement).
// Space Complexity: O(k), where k is the range of the input (maxElement).