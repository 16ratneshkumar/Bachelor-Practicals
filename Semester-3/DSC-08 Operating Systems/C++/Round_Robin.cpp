// Round Robin

#include <iostream>

void display(std::string name_of_process[], int burst_time[],int number_of_processes,int waiting_time[],int turnaround_time[]){
    double total_waiting_time = 0;
    double total_turnaround_time = 0;
    std::cout<<"Name Of Process\tBurst Time\tWaiting Time\tTurnAround Time"<<std::endl;
    for (int num=0;num<number_of_processes;num++){
        total_waiting_time += waiting_time[num];
        total_turnaround_time += turnaround_time[num];
        std::cout<<name_of_process[num]<<"\t\t"<<burst_time[num]<<"\t\t"<<waiting_time[num]<<"\t\t"<<turnaround_time[num]<<std::endl;
    }
    std::cout<<"\nAverage Waiting Time is:: "<<total_waiting_time / number_of_processes<<"\nAverage TurnAround Time is:: "<<total_turnaround_time / number_of_processes<<std::endl;
}
    

void Round_Robin(std::string name_of_process[], int burst_time[],int number_of_processes){
    int waiting_time[number_of_processes];
    int turnaround_time[number_of_processes];
    int remaining_time[number_of_processes];
    std::copy(burst_time,burst_time+number_of_processes,remaining_time);
    int clock = 0;
    int time_quantum;
    std::cout<<"Enter Time Quantum:: ";
    std::cin>>time_quantum;
    while (true){
        bool done = true;
        for (int num=0;num<number_of_processes;num++){
            if (remaining_time[num]>0){
                if (remaining_time[num] >time_quantum) {
                    done = false;
                    clock +=time_quantum;
                    remaining_time[num] -= time_quantum;
                } else{
                    clock +=remaining_time[num];
                    remaining_time[num] = 0;
                    waiting_time[num] = clock - burst_time[num];
                    turnaround_time[num] = waiting_time[num] + burst_time[num];
                }
            }
        }
        if (done){
            break;
        }
    }
    display(name_of_process, burst_time, number_of_processes,waiting_time,turnaround_time);
}
        
int main(){
    int number_of_processes;

    std::cout<<"Enter the number of processes: ";
    std::cin>>number_of_processes;
    std::string name_of_process[number_of_processes];
    int burst_time[number_of_processes];

    for (int i=0;i<number_of_processes;i++){
        std::cout<<"Enter Name of Process:: ";
        std::cin>>name_of_process[i];
        std::cout<<"Enter Burst Time of Process "<<name_of_process[i]<<":: ";
        std::cin>>burst_time[i];
    }
    Round_Robin(name_of_process,burst_time,number_of_processes);
}
