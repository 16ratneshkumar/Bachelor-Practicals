// Dynamic_Storage_Allocation

use std::io;
fn first_fit(no_of_frames: usize, memory: &mut Vec<(String, usize)>, process: (String, usize)){
    let mut flag:bool = false;
    for frames in 0..no_of_frames{
        if memory[frames].0 == "free" && memory[frames].1 >= process.1{
            memory[frames].0 = process.0;
            display(memory);
            flag = true;
            break;
        }
    }
    if !flag{
        println!("\nYou Have Not Enough Space To Run New Process");
    }
}
fn best_fit(no_of_frames: usize, memory: &mut Vec<(String, usize)>, process: (String, usize)) {
    let mut flag: Option<usize> = None;
    for frame in 0..no_of_frames {
        if memory[frame].0 == "free" && memory[frame].1 >= process.1 {
            if let Some(current_flag) = flag {
                if memory[frame].1 < memory[current_flag].1 {
                    flag = Some(frame);
                }
            } else {
                flag = Some(frame);
            }
        }
    }
    if let Some(best_frame) = flag {
        memory[best_frame].0 = process.0.clone();
        display(memory);
    } else {
        println!("\nYou do not have enough space to run the new process.");
    }
}
fn worst_fit(no_of_frames: usize, memory: &mut Vec<(String, usize)>, process: (String, usize)) {
    let mut flag: Option<usize> = None;
    for frame in 0..no_of_frames {
        if memory[frame].0 == "free" && memory[frame].1 >= process.1 {
            if let Some(current_flag) = flag {
                if memory[frame].1 > memory[current_flag].1 {
                    flag = Some(frame);
                }
            } else {
                flag = Some(frame);
            }
        }
    }
    if let Some(best_frame) = flag {
        memory[best_frame].0 = process.0.clone();
        display(memory);
    } else {
        println!("\nYou do not have enough space to run the new process.");
    }
}
fn display(memory: &Vec<(String, usize)>) {
    let mut count=1;
    println!("Memory Status:");
    for (state, size) in memory {
        println!("Frame: {} | Process: {} | Size: {}", count, state, size);
        count+=1;
    }
}
fn main() {
    // let mut memory = vec![
    //     ("used".to_string(), 150),
    //     ("free".to_string(), 120),
    //     ("free".to_string(), 110),
    //     ("free".to_string(), 200),
    // ];
    // let process = ("Process1".to_string(), 110);

    let mut memory = Vec::new();
    loop {
        println!("Enter memory type (used/free) and value, or 'q' to quit:");
        let mut input = String::new();
        io::stdin().read_line(&mut input).expect("Failed to read line");
        let input = input.trim();

        if input == "q" {
            break;
        }

        let mut parts = input.split_whitespace();
        let memory_type = parts.next().expect("Invalid input");
        let value = parts.next().expect("Invalid input").parse::<usize>().expect("Invalid input");

        memory.push((memory_type.to_string(), value));
    }

    println!("Enter process name and value:");
    let mut input = String::new();
    io::stdin().read_line(&mut input).expect("Failed to read line");
    let input = input.trim();
    let mut parts = input.split_whitespace();
    let process_name = parts.next().expect("Invalid input").to_string();
    let process_value = parts.next().expect("Invalid input").parse::<usize>().expect("Invalid input");

    let process = (process_name, process_value);

    println!("Main Menu \n1. First Fit\n2. Best Fit\n3. Worst Fit\nEnter your Choice:: ");
    let mut input = String::new();
    io::stdin().read_line(&mut input).expect("Failed to read line");
    let choice:usize = input.trim().parse().expect("Please enter number of processes:: ");

    if choice==1{
        first_fit(memory.len(), &mut memory, process);
    }else if choice==2{
        best_fit(memory.len(), &mut memory, process);
    }else{
        worst_fit(memory.len(), &mut memory, process)
    }
}