# First Come First Serve Scheduling Algorithm (FCFS)


def First_Come_First_Serve(name_of_process, burst_time, number_of_processes):

    waiting_time = 0
    total_waiting_time = 0
    total_turnaround_time = 0

    print("Name Of Process\tBurst Time\tWaiting Time\tTurnAround Time")

    for i in range(number_of_processes):
        turnaround_time = waiting_time + burst_time[i]
        total_turnaround_time += turnaround_time

        print(f"{name_of_process[i]}\t\t{burst_time[i]}\t\t{waiting_time}\t\t{turnaround_time}")
        
        total_waiting_time += waiting_time
        waiting_time += burst_time[i]
    print(f"\nAverage Waiting Time is:: {total_waiting_time / number_of_processes}\nAverage TurnAround Time is:: {total_turnaround_time / number_of_processes}")


def main():
    name_of_process = []
    burst_time = []

    number_of_processes = int(input("Enter the number of processes: "))

    for i in range(number_of_processes):
        name_of_process.append(input(f"Enter name of process {i + 1}: "))
        burst_time.append(int(input(f"Enter burst time for process {name_of_process[i]}: ")))

    First_Come_First_Serve(name_of_process, burst_time, number_of_processes)


if __name__ == "__main__":
    main()