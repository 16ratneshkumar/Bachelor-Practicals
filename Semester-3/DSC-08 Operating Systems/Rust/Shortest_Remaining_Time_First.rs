//  Shortest Remaining Time First Scheduling Algorithm (SRTF)

use std::io;

fn display(name_of_process:Vec<String>, burst_time:Vec<i32>, arrival_time:Vec<i32>, number_of_processes:usize, waiting_time:Vec<i32>,turnaround_time:Vec<i32>){
    let mut total_waiting_time:i32 = 0;
    let mut total_turnaround_time:i32 = 0;
    println!("Name Of Process\tBurst Time\tArrival Time\tWaiting Time\tTurnAround Time");
    for num in 0..number_of_processes{
        total_waiting_time+=waiting_time[num];
        total_turnaround_time+=turnaround_time[num];

        println!("{}\t\t{}\t\t{}\t\t{}\t\t{}",name_of_process[num],burst_time[num],arrival_time[num],waiting_time[num],turnaround_time[num]);
    }
    println!("\nAverage Waiting Time is:: {}\nAverage TurnAround Time is:: {}",total_waiting_time as f64 / number_of_processes as f64,total_turnaround_time as f64/ number_of_processes as f64);
} 

fn shortest_remaining_time_first(name_of_process:Vec<String>, burst_time:Vec<i32>, arrival_time:Vec<i32>, number_of_processes:usize){
    let mut remaining_time = burst_time.clone();
    let mut waiting_time = vec![0;number_of_processes];
    let mut turnaround_time = vec![0;number_of_processes];
    let mut completed:usize = 0 ;
    let mut clock:i32 = 0 ;
    let mut min_burst = i32::MAX;
    let mut shortest: i32 = -1;
    let mut finished:bool = false;

    while completed != number_of_processes{
        for num in 0..number_of_processes{
            if arrival_time[num] <= clock && remaining_time[num] < min_burst && remaining_time[num] > 0{
                min_burst = remaining_time[num];
                shortest = num as i32;
                finished = true;
            }
        }

        if !finished{
            clock += 1;
            continue;
        }

        remaining_time[shortest as usize] -= 1;
        min_burst = remaining_time[shortest as usize];
        if min_burst == 0{
            min_burst = i32::MAX;
        }

        if remaining_time[shortest as usize] == 0{
            completed += 1;
            finished = false;
            let finish_time:i32 = clock + 1;
            waiting_time[shortest as usize] = finish_time - burst_time[shortest as usize] - arrival_time[shortest as usize];
            turnaround_time[shortest as usize] = finish_time - arrival_time[shortest as usize];

            if waiting_time[shortest as usize] < 0{
                waiting_time[shortest as usize] = 0;
            }
        }

        clock += 1
    }

    display(name_of_process, burst_time, arrival_time, number_of_processes,waiting_time,turnaround_time);
}

    fn main(){
        let mut processes_count = String::new();
        println!("Enter the number of processes: ");
        io::stdin().read_line(&mut processes_count).expect("Failed to read line");
        let number_of_processes: usize = processes_count.trim().parse().expect("Please enter number of processes:: ");
    
        let mut name_of_process =Vec::new();
        let mut burst_time = Vec::new();
        let mut arrival_time = Vec::new();
    
        for i in 0..number_of_processes {
            let mut process_name = String::new();
            let mut burst = String::new();
            let mut arrival = String::new();
    
            println!("Enter name of process {}: ", i + 1);
            io::stdin().read_line(&mut process_name).expect("Failed to read line");
            name_of_process.push(process_name.trim().to_string());
    
            println!("Enter burst time for process {}: ", name_of_process[i]);
            io::stdin().read_line(&mut burst).expect("Failed to read line");
            let burst_value: i32 = burst.trim().parse().expect("Please enter burst time of processes:: ");
            burst_time.push(burst_value);

            println!("Enter arrival time for process {}: ", name_of_process[i]);
            io::stdin().read_line(&mut arrival).expect("Failed to read line");
            let arrival_value: i32 = arrival.trim().parse().expect("Please enter arrival time of processes:: ");
            arrival_time.push(arrival_value);
        }
    
        // let number_of_processes:usize =5;
        // let name_of_process = vec!["P1".to_string(),"P2".to_string(),"P3".to_string(),"P4".to_string(),"P5".to_string()];
        // let burst_time = vec![6,3,2,8,9];
        // let arrival_time = vec![0,1,2,3,4];

        shortest_remaining_time_first(name_of_process, burst_time, arrival_time, number_of_processes);
    }