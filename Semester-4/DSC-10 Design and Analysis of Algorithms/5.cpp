// Write a program to multiply two matrices using the Strassen’s algorithm for matrix multiplication.

#include <iostream>
#include <cmath>
using namespace std;

const int MAX = 64; // Maximum allowed matrix size (must be a power of 2)

// Function to add matrices
void add(int A[MAX][MAX], int B[MAX][MAX], int C[MAX][MAX], int size) {
    for (int i = 0; i < size; ++i)
        for (int j = 0; j < size; ++j)
            C[i][j] = A[i][j] + B[i][j];
}

// Function to subtract matrices
void subtract(int A[MAX][MAX], int B[MAX][MAX], int C[MAX][MAX], int size) {
    for (int i = 0; i < size; ++i)
        for (int j = 0; j < size; ++j)
            C[i][j] = A[i][j] - B[i][j];
}

// Strassen multiplication
void strassen(int A[MAX][MAX], int B[MAX][MAX], int C[MAX][MAX], int size) {
    if (size == 1) {
        C[0][0] = A[0][0] * B[0][0];
        return;
    }

    int newSize = size / 2;
    int A11[MAX][MAX], A12[MAX][MAX], A21[MAX][MAX], A22[MAX][MAX];
    int B11[MAX][MAX], B12[MAX][MAX], B21[MAX][MAX], B22[MAX][MAX];
    int C11[MAX][MAX], C12[MAX][MAX], C21[MAX][MAX], C22[MAX][MAX];
    int M1[MAX][MAX], M2[MAX][MAX], M3[MAX][MAX], M4[MAX][MAX];
    int M5[MAX][MAX], M6[MAX][MAX], M7[MAX][MAX];
    int temp1[MAX][MAX], temp2[MAX][MAX];

    // Dividing A and B into 4 sub-matrices
    for (int i = 0; i < newSize; ++i)
        for (int j = 0; j < newSize; ++j) {
            A11[i][j] = A[i][j];
            A12[i][j] = A[i][j + newSize];
            A21[i][j] = A[i + newSize][j];
            A22[i][j] = A[i + newSize][j + newSize];

            B11[i][j] = B[i][j];
            B12[i][j] = B[i][j + newSize];
            B21[i][j] = B[i + newSize][j];
            B22[i][j] = B[i + newSize][j + newSize];
        }

    // M1 = (A11 + A22) * (B11 + B22)
    add(A11, A22, temp1, newSize);
    add(B11, B22, temp2, newSize);
    strassen(temp1, temp2, M1, newSize);

    // M2 = (A21 + A22) * B11
    add(A21, A22, temp1, newSize);
    strassen(temp1, B11, M2, newSize);

    // M3 = A11 * (B12 - B22)
    subtract(B12, B22, temp1, newSize);
    strassen(A11, temp1, M3, newSize);

    // M4 = A22 * (B21 - B11)
    subtract(B21, B11, temp1, newSize);
    strassen(A22, temp1, M4, newSize);

    // M5 = (A11 + A12) * B22
    add(A11, A12, temp1, newSize);
    strassen(temp1, B22, M5, newSize);

    // M6 = (A21 - A11) * (B11 + B12)
    subtract(A21, A11, temp1, newSize);
    add(B11, B12, temp2, newSize);
    strassen(temp1, temp2, M6, newSize);

    // M7 = (A12 - A22) * (B21 + B22)
    subtract(A12, A22, temp1, newSize);
    add(B21, B22, temp2, newSize);
    strassen(temp1, temp2, M7, newSize);

    // C11 = M1 + M4 - M5 + M7
    add(M1, M4, temp1, newSize);
    subtract(temp1, M5, temp2, newSize);
    add(temp2, M7, C11, newSize);

    // C12 = M3 + M5
    add(M3, M5, C12, newSize);

    // C21 = M2 + M4
    add(M2, M4, C21, newSize);

    // C22 = M1 - M2 + M3 + M6
    subtract(M1, M2, temp1, newSize);
    add(temp1, M3, temp2, newSize);
    add(temp2, M6, C22, newSize);

    // Combining the 4 submatrices into result matrix C
    for (int i = 0; i < newSize; ++i)
        for (int j = 0; j < newSize; ++j) {
            C[i][j] = C11[i][j];
            C[i][j + newSize] = C12[i][j];
            C[i + newSize][j] = C21[i][j];
            C[i + newSize][j + newSize] = C22[i][j];
        }
}

// Function to print the matrix
void printMatrix(int matrix[MAX][MAX], int size) {
    for (int i = 0; i < size; ++i) {
        for (int j = 0; j < size; ++j)
            cout << matrix[i][j] << " ";
        cout << endl;
    }
}

int main() {
    int n;
    cout << "Enter size of matrix (must be power of 2 <= " << MAX << "): ";
    cin >> n;

    int A[MAX][MAX], B[MAX][MAX], C[MAX][MAX] = {0};

    cout << "Enter elements of matrix A:\n";
    for (int i = 0; i < n; ++i)
        for (int j = 0; j < n; ++j)
            cin >> A[i][j];

    cout << "Enter elements of matrix B:\n";
    for (int i = 0; i < n; ++i)
        for (int j = 0; j < n; ++j)
            cin >> B[i][j];

    strassen(A, B, C, n);

    cout << "\nResultant matrix after Strassen multiplication:\n";
    printMatrix(C, n);

    return 0;
}
// Sample Input/Output:
// Enter size of matrix (must be power of 2 <= 64): 2 
// Enter elements of matrix A: 1 2 3 4 Enter elements of matrix B: 5 6 7 8 Resultant matrix after Strassen multiplication: 19 22 43 50
// Time Complexity: O(n^log2(7)) ~ O(n^2.81)
// Space Complexity: O(n^2) for the temporary matrices used in the algorithm.
// Note: The size of the matrix must be a power of 2 for this implementation. If the size is not a power of 2, you can pad the matrix with zeros to make it a power of 2.