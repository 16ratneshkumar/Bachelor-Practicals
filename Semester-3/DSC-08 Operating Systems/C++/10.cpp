//  Shortest Remaining Time First Scheduling Algorithm (SRTF)

#include <iostream>

void display(std::string name_of_process[], int burst_time[], int arrival_time[],int number_of_processes,int waiting_time[],int turnaround_time[]){
    double total_waiting_time = 0;
    double total_turnaround_time = 0;
    std::cout<<"Name Of Process\tBurst Time\tArrival Time\tWaiting Time\tTurnAround Time"<<std::endl;
    for (int num=0;num<number_of_processes;num++){
        total_waiting_time += waiting_time[num];
        total_turnaround_time += turnaround_time[num];
        std::cout<<name_of_process[num]<<"\t\t"<<burst_time[num]<<"\t\t"<<arrival_time[num]<<"\t\t"<<waiting_time[num]<<"\t\t"<<turnaround_time[num]<<std::endl;
    }
    std::cout<<"\nAverage Waiting Time is:: "<<total_waiting_time / number_of_processes<<"\nAverage TurnAround Time is:: "<<total_turnaround_time / number_of_processes<<std::endl;
}
  

void shortest_remaining_time_first(std::string name_of_process[], int number_of_processes, int burst_time[], int arrival_time[]){
    int waiting_time[number_of_processes];
    int turnaround_time[number_of_processes];
    int remaining_time[number_of_processes];
    std::copy(burst_time,burst_time+number_of_processes,remaining_time);
    int clock = 0;
    int completed = 0;
    float min_burst = float('inf');
    signed int shortest = -1;
    bool finished = false;

    while (completed != number_of_processes){
        for (int num=0;num<number_of_processes;num++){
            if (arrival_time[num] <= clock and remaining_time[num] < min_burst and remaining_time[num] > 0){
                min_burst = remaining_time[num];
                shortest = num;
                finished = true;
            }
        }

        if (not finished){
            clock += 1;
            continue;
        }

        remaining_time[shortest] -= 1;
        min_burst = remaining_time[shortest];
        if (min_burst == 0){
            min_burst = float('inf');
        }

        if (remaining_time[shortest] == 0){
            completed += 1;
            finished = false;
            int finish_time = clock + 1;
            waiting_time[shortest] = finish_time - burst_time[shortest] - arrival_time[shortest];
            turnaround_time[shortest] = finish_time - arrival_time[shortest];
            }
            if (waiting_time[shortest] < 0){
                waiting_time[shortest] = 0;
                }

        clock += 1;
    }
    display(name_of_process, burst_time, arrival_time, number_of_processes,waiting_time,turnaround_time);
}

int main(){
    int number_of_processes;

    std::cout<<"Enter the number of processes: ";
    std::cin>>number_of_processes;
    std::string name_of_process[number_of_processes];
    int burst_time[number_of_processes];
    int arrival_time[number_of_processes];

    for (int i=0;i<number_of_processes;i++){
        std::cout<<"Enter Name of Process:: ";
        std::cin>>name_of_process[i];
        std::cout<<"Enter Burst Time of Process "<<name_of_process[i]<<":: ";
        std::cin>>burst_time[i];
        std::cout<<"Enter Arrival Time of Process "<<name_of_process[i]<<":: ";
        std::cin>>arrival_time[i];        
    }
    // std::string name_of_process[5] = {"1","2","3","4","5"};
    // int number_of_processes= 5;
    // int burst_time[5]= {5,4,3,2,6};
    // int arrival_time[5]= {1,0,3,5,2};
    shortest_remaining_time_first(name_of_process, number_of_processes, burst_time,arrival_time);
}