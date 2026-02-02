#include <iostream>
#include <vector>
#include <algorithm>
#include <chrono>
#include <random>
#include <fstream>

using namespace std;

// --- Insertion Sort ---
void insertionSort(vector<int>& arr, long long &comparisons) {
    int n = arr.size();
    for (int i = 1; i < n; i++) {
        int key = arr[i];
        int j = i - 1;
        while (j >= 0 && arr[j] > key) {
            comparisons++;
            arr[j + 1] = arr[j];
            j--;
        }
        if (j >= 0) comparisons++;
        arr[j + 1] = key;
    }
}

// --- Merge Sort ---
void merge(vector<int>& arr, int left, int mid, int right, long long &comparisons) {
    int n1 = mid - left + 1;
    int n2 = right - mid;
    vector<int> L(n1), R(n2);
    for (int i = 0; i < n1; i++) L[i] = arr[left + i];
    for (int j = 0; j < n2; j++) R[j] = arr[mid + 1 + j];

    int i = 0, j = 0, k = left;
    while (i < n1 && j < n2) {
        comparisons++;
        if (L[i] <= R[j]) { arr[k] = L[i]; i++; }
        else { arr[k] = R[j]; j++; }
        k++;
    }
    while (i < n1) { arr[k] = L[i]; i++; k++; }
    while (j < n2) { arr[k] = R[j]; j++; k++; }
}

void mergeSort(vector<int>& arr, int left, int right, long long &comparisons) {
    if (left < right) {
        int mid = left + (right - left) / 2;
        mergeSort(arr, left, mid, comparisons);
        mergeSort(arr, mid + 1, right, comparisons);
        merge(arr, left, mid, right, comparisons);
    }
}

// --- Heap Sort ---
void heapify(vector<int>& arr, int n, int i, long long &comparisons) {
    int largest = i;
    int left = 2 * i + 1;
    int right = 2 * i + 2;
    if (left < n) {
        comparisons++;
        if (arr[left] > arr[largest]) largest = left;
    }
    if (right < n) {
        comparisons++;
        if (arr[right] > arr[largest]) largest = right;
    }
    if (largest != i) {
        swap(arr[i], arr[largest]);
        heapify(arr, n, largest, comparisons);
    }
}

void heapSort(vector<int>& arr, long long &comparisons) {
    int n = arr.size();
    for (int i = n / 2 - 1; i >= 0; i--) heapify(arr, n, i, comparisons);
    for (int i = n - 1; i > 0; i--) {
        swap(arr[0], arr[i]);
        heapify(arr, i, 0, comparisons);
    }
}

// --- Quick Sort ---
int partition(vector<int>& arr, int low, int high, long long &comparisons) {
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
    return i + 1;
}

void quickSort(vector<int>& arr, int low, int high, long long &comparisons) {
    if (low < high) {
        int pi = partition(arr, low, high, comparisons);
        quickSort(arr, low, pi - 1, comparisons);
        quickSort(arr, pi + 1, high, comparisons);
    }
}

int main() {
    ofstream outFile("sorting_results.csv");
    outFile << "Size,Insertion,Merge,Heap,Quick\n";

    random_device rd;
    mt19937 g(rd());

    for (int size = 30; size <= 1000; size += 10) { // Approx 100 steps
        long long totalInsertion = 0, totalMerge = 0, totalHeap = 0, totalQuick = 0;
        int trials = 10;

        for (int t = 0; t < trials; t++) {
            vector<int> source(size);
            for (int i = 0; i < size; i++) source[i] = i;
            shuffle(source.begin(), source.end(), g);

            vector<int> arr;
            long long comp;

            arr = source; comp = 0; insertionSort(arr, comp); totalInsertion += comp;
            arr = source; comp = 0; mergeSort(arr, 0, size - 1, comp); totalMerge += comp;
            arr = source; comp = 0; heapSort(arr, comp); totalHeap += comp;
            arr = source; comp = 0; quickSort(arr, 0, size - 1, comp); totalQuick += comp;
        }

        outFile << size << "," 
                << totalInsertion / trials << "," 
                << totalMerge / trials << "," 
                << totalHeap / trials << "," 
                << totalQuick / trials << "\n";
    }

    outFile.close();
    cout << "Results saved to sorting_results.csv" << endl;
    return 0;
}
