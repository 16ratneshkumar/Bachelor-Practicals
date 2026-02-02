# Round Robin

def display(name_of_process, burst_time, number_of_processes,waiting_time,turnaround_time):
    total_waiting_time = sum(waiting_time)
    total_turnaround_time = sum(turnaround_time)
    print("Name Of Process\tBurst Time\tWaiting Time\tTurnAround Time")
    for num in range(number_of_processes):
        print(f"{name_of_process[num]}\t\t{burst_time[num]}\t\t{waiting_time[num]}\t\t{turnaround_time[num]}")
    print(f"\nAverage Waiting Time is:: {total_waiting_time / number_of_processes}\nAverage TurnAround Time is:: {total_turnaround_time / number_of_processes}")
    

def Round_Robin(name_of_process, burst_time, number_of_processes):
    waiting_time = [0] * number_of_processes
    turnaround_time = [0] * number_of_processes
    remaining_time = burst_time.copy()
    clock = 0
    time_quantum = int(input("Enter Time Quantum:: "))
    while True:
        done = True
        for num in range(number_of_processes):
            if remaining_time[num]>0:
                if remaining_time[num] >time_quantum :
                    done = False
                    clock +=time_quantum
                    remaining_time[num] -= time_quantum
                else:
                    clock +=remaining_time[num]
                    remaining_time[num] = 0
                    waiting_time[num] = clock - burst_time[num]
                    turnaround_time[num] = waiting_time[num] + burst_time[num]
        if done:
            break
    display(name_of_process, burst_time, number_of_processes,waiting_time,turnaround_time)
        

def main():
    name_of_process = []
    burst_time = []

    number_of_processes = int(input("Enter the number of processes: "))

    for i in range(number_of_processes):
        name_of_process.append(input(f"Enter name of process {i + 1}: "))
        burst_time.append(int(input(f"Enter burst time for process {name_of_process[i]}: ")))

    Round_Robin(name_of_process, burst_time, number_of_processes)

if __name__ == "__main__":
    main()