// Write a program to sort the elements of an array using Heap Sort (The program should report the number of comparisons).

#include <iostream>
using namespace std;

void heapify(int arr[], int n, int i, int &comparisons) {
    int largest = i; 
    int left = 2 * i + 1; 
    int right = 2 * i + 2;

    if (left < n) {
        comparisons++;
        if (arr[left] > arr[largest]) {
            largest = left;
        }
    }

    if (right < n) {
        comparisons++;
        if (arr[right] > arr[largest]) {
            largest = right;
        }
    }

    if (largest != i) {
        swap(arr[i], arr[largest]);
        heapify(arr, n, largest, comparisons);
    }
}

void heapsort(int arr[], int n, int &comparisons) {
    for (int i = n / 2 - 1; i >= 0; i--) {
        heapify(arr, n, i, comparisons);
    }

    for (int i = n - 1; i > 0; i--) {
        swap(arr[0], arr[i]);
        heapify(arr, i, 0, comparisons);
    }
}

int main(){
    int arr[] = {12, 11, 13, 5, 6, 7};
    int n = sizeof(arr) / sizeof(arr[0]);
    int comparisons = 0;

    heapsort(arr, n, comparisons);

    cout << "Sorted array is \n";
    for (int i = 0; i < n; i++) {
        cout << arr[i] << " ";
    }
    cout << "\nNumber of comparisons: " << comparisons << endl;
    return 0;
}

// Output:
// Sorted array: 5 6 11 12 13
// Number of comparisons: 14
// Time Complexity: O(n log n) for all cases (worst, average, best).
// Space Complexity: O(1) as it sorts the array in place.
// The heap sort algorithm is not a stable sort, meaning that it does not preserve the relative order of equal elements.
// However, it is an in-place sorting algorithm, which means it requires only a constant amount of additional space.
