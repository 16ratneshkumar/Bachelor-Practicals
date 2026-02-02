// Round_Robin

use std::io;

fn display(name_of_process:Vec<String>, burst_time:Vec<i32>,number_of_processes:usize,waiting_time:Vec<i32>,turnaround_time:Vec<i32>){
    let mut total_waiting_time:i32 = 0;
    let mut total_turnaround_time:i32 = 0;
    println!("Name Of Process\tBurst Time\tWaiting Time\tTurnAround Time");
    for num in 0..number_of_processes{
        total_waiting_time+=waiting_time[num];
        total_turnaround_time+=turnaround_time[num];

        println!("{}\t\t{}\t\t{}\t\t{}",name_of_process[num],burst_time[num],waiting_time[num],turnaround_time[num]);
    }
    println!("\nAverage Waiting Time is:: {}\nAverage TurnAround Time is:: {}",total_waiting_time as f64 / number_of_processes as f64,total_turnaround_time as f64/ number_of_processes as f64);
}

fn round_robin(name_of_process:Vec<String>, burst_time:Vec<i32>, number_of_processes:usize){
    let mut waiting_time = vec![0;number_of_processes];
    let mut turnaround_time = vec![0;number_of_processes];
    let mut remaining_time = burst_time.clone();
    let mut clock:i32 = 0;

    let mut quantum = String::new();
    println!("Enter Time Quantum:: ");
    io::stdin().read_line(&mut quantum).expect("Failed to read line");
    let time_quantum: i32 = quantum.trim().parse().expect("Please Enter Time Quantum");


    loop{
        let mut done:bool = true;
        for num in 0..number_of_processes{
            if remaining_time[num]>0{
                if remaining_time[num] >time_quantum{
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
        if done{
            break;
        }
    }
    display(name_of_process, burst_time, number_of_processes,waiting_time,turnaround_time)
}



fn main(){
    let mut processes_count = String::new();
    println!("Enter the number of processes: ");
    io::stdin().read_line(&mut processes_count).expect("Failed to read line");
    let number_of_processes: usize = processes_count.trim().parse().expect("Please enter a number of processes:: ");

    let mut name_of_process =Vec::new();
    let mut burst_time = Vec::new();

    for i in 0..number_of_processes {
        let mut process_name = String::new();
        let mut burst = String::new();

        println!("Enter name of process {}: ", i + 1);
        io::stdin().read_line(&mut process_name).expect("Failed to read line");
        name_of_process.push(process_name.trim().to_string());

        println!("Enter burst time for process {}: ", name_of_process[i]);
        io::stdin().read_line(&mut burst).expect("Failed to read line");
        let burst_value: i32 = burst.trim().parse().expect("Please enter burst time of processes:: ");
        burst_time.push(burst_value);
    }

    // let number_of_processes:usize =5;
    // let name_of_process = vec!["P1".to_string(),"P2".to_string(),"P3".to_string(),"P4".to_string(),"P5".to_string()];
    // let burst_time = vec![6,3,2,8,9];

    round_robin(name_of_process, burst_time, number_of_processes);
}