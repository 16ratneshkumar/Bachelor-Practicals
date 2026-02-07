#include <iostream>
#include <vector>
#include <ctime>

using namespace std;

int partition(vector<int>& arr, int low, int high) {
    int pivot = arr[high];
    int i = (low - 1);

    for (int j = low; j <= high - 1; j++) {
        if (arr[j] < pivot) {
            i++;
            swap(arr[i], arr[j]);
        }
    }
    swap(arr[i + 1], arr[high]);
    return (i + 1);
}

int randomizedPartition(vector<int>& arr, int low, int high) {
    int n = high - low + 1;
    int pivotIndex = low + rand() % n;
    swap(arr[pivotIndex], arr[high]);
    return partition(arr, low, high);
}

int randomizedSelect(vector<int>& arr, int low, int high, int i) {
    if (low == high) {
        return arr[low];
    }

    int q = randomizedPartition(arr, low, high);
    int k = q - low + 1;

    if (i == k) {
        return arr[q];
    } else if (i < k) {
        return randomizedSelect(arr, low, q - 1, i);
    } else {
        return randomizedSelect(arr, q + 1, high, i - k);
    }
}

int main() {
    srand(time(0));
    int n, i;
    cout << "Enter the number of elements: ";
    cin >> n;

    vector<int> arr(n);
    cout << "Enter " << n << " elements: ";
    for (int j = 0; j < n; j++) {
        cin >> arr[j];
    }

    cout << "Enter the value of i (to find the i-th smallest element): ";
    cin >> i;

    if (i > 0 && i <= n) {
        int result = randomizedSelect(arr, 0, n - 1, i);
        cout << "The " << i << "-th smallest element is: " << result << endl;
    } else {
        cout << "Invalid value for i." << endl;
    }

    return 0;
}
