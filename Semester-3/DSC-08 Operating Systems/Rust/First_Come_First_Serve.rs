//First Come First Serve Scheduling Algorithm (FCFS)
use std::io;
fn first_come_first_serve(name_of_process:Vec<String>, burst_time:Vec<i32>,number_of_processes:usize){
    
    let mut waiting_time = 0;
    let mut total_waiting_time = 0;
    let mut total_turnaround_time = 0;    

    println!("Name Of Process\tBurst Time\tWaiting Time\tTurnAround Time");

    for i in 0..number_of_processes{
        let turnaround_time = waiting_time + burst_time[i];
        total_turnaround_time+=turnaround_time;
        
       println!("{}\t\t{}\t\t{}\t\t{}",name_of_process[i],burst_time[i],waiting_time,turnaround_time);
       
       total_waiting_time+=waiting_time;
       waiting_time += burst_time[i];
    }
    println!("\nAverage Waiting Time is:: {}\nAverage TurnAround Time is::{}",total_waiting_time as f64/number_of_processes as f64,total_turnaround_time as f64/number_of_processes as f64);
}

fn main(){
    let mut processes_count = String::new();
    println!("Enter the number of processes: ");
    io::stdin().read_line(&mut processes_count).expect("Failed to read line");
    let number_of_processes: usize = processes_count.trim().parse().expect("Please enter number of process:: ");

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
        let burst_value: i32 = burst.trim().parse().expect("Please enter burst timeof processes:: ");
        burst_time.push(burst_value);
    }

    // let number_of_processes:usize =5;
    // let name_of_process = vec!["P1".to_string(),"P2".to_string(),"P3".to_string(),"P4".to_string(),"P5".to_string()];
    // let burst_time = vec![6,3,2,8,9];

    first_come_first_serve(name_of_process,burst_time,number_of_processes);
}