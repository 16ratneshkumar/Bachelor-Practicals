import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

def plot_results():
    try:
        df = pd.read_csv('sorting_results.csv')
    except FileNotFoundError:
        print("Data file not found. Please run the C++ collector first.")
        return

    plt.figure(figsize=(10, 6))
    
    plt.plot(df['Size'], df['Insertion'], label='Insertion Sort')
    plt.plot(df['Size'], df['Merge'], label='Merge Sort')
    plt.plot(df['Size'], df['Heap'], label='Heap Sort')
    plt.plot(df['Size'], df['Quick'], label='Quick Sort')

    n = df['Size']
    scale = df['Merge'].iloc[-1] / (n.iloc[-1] * np.log2(n.iloc[-1]))
    plt.plot(n, scale * n * np.log2(n), '--', label='n log n (scaled)', color='gray')

    plt.xlabel('Input Size (n)')
    plt.ylabel('Average Comparisons')
    plt.title('Sorting Algorithm Comparison: Comparisons vs. Input Size')
    plt.legend()
    plt.grid(True)
    
    plt.savefig('sorting_comparison.png')
    print("Plot saved as sorting_comparison.png")

if __name__ == "__main__":
    plot_results()
