# Shortest Remaining Time First Scheduling Algorithm (SRTF)

def display(name_of_process, burst_time, arrival_time, number_of_processes,waiting_time,turnaround_time):
    print(waiting_time,turnaround_time)
    total_waiting_time = sum(waiting_time)
    total_turnaround_time = sum(turnaround_time)
    print("Name Of Process\tBurst Time\tArrival Time\tWaiting Time\tTurnAround Time")
    for num in range(number_of_processes):
        print(f"{name_of_process[num]}\t\t{burst_time[num]}\t\t{arrival_time[num]}\t\t{waiting_time[num]}\t\t{turnaround_time[num]}")
    print(f"\nAverage Waiting Time is:: {total_waiting_time / number_of_processes}\nAverage TurnAround Time is:: {total_turnaround_time / number_of_processes}")
    

def shortest_remaining_time_first(name_of_process, number_of_processes, burst_time, arrival_time):
    remaining_time = burst_time.copy()
    waiting_time = [0] * number_of_processes
    turnaround_time = [0] * number_of_processes
    completed = 0 
    clock = 0 
    min_burst = float('inf')
    shortest = -1
    finished = False

    while completed != number_of_processes:
        for num in range(number_of_processes):
            if arrival_time[num] <= clock and remaining_time[num] < min_burst and remaining_time[num] > 0:
                min_burst = remaining_time[num]
                shortest = num
                finished = True

        if not finished:
            clock += 1
            continue

        remaining_time[shortest] -= 1
        min_burst = remaining_time[shortest]
        if min_burst == 0:
            min_burst = float('inf')

        if remaining_time[shortest] == 0:
            completed += 1
            finished = False
            finish_time = clock + 1
            waiting_time[shortest] = finish_time - burst_time[shortest] - arrival_time[shortest]
            turnaround_time[shortest] = finish_time - arrival_time[shortest]

            if waiting_time[shortest] < 0:
                waiting_time[shortest] = 0

        clock += 1

    display(name_of_process, burst_time, arrival_time, number_of_processes,waiting_time,turnaround_time)

def main():
    name_of_process = []
    burst_time = []
    arrival_time = []

    number_of_processes = int(input("Enter the number of processes: "))

    for i in range(number_of_processes):
        name_of_process.append(input(f"Enter name of process {i + 1}: "))
        burst_time.append(int(input(f"Enter burst time for process {name_of_process[i]}: ")))
        arrival_time.append(int(input(f"Enter arrival time for process {name_of_process[i]}: ")))


    shortest_remaining_time_first(name_of_process, number_of_processes, burst_time, arrival_time)



if __name__ == "__main__":
    main()