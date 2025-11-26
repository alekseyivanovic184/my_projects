#include <stdlib.h>
#include "../include/scheduler.h"

Scheduler* create_scheduler(int capacity){

    Scheduler* my_scheduler = (Scheduler*)malloc(sizeof(Scheduler));

    if(!my_scheduler){
        //printf("Memory allocation for schedular failed!\n");
        return NULL;
    }
    
    my_scheduler->process_queue = heap_create(capacity, sizeof(Process), compare);

    if(!my_scheduler->process_queue){
        //printf("Allocation for process queue has failed!\n");
        free(my_scheduler);
        return NULL;
    }
    my_scheduler->current_process = NULL;
    my_scheduler->time_slice = 10;

    return my_scheduler;
}

void destroy_scheduler(Scheduler* scheduler){

    if(!scheduler) return;
    
    if (scheduler->current_process) {
    free(scheduler->current_process);
    scheduler->current_process = NULL;
    }

    if(scheduler->process_queue){
        heap_destroy(scheduler->process_queue);
        scheduler->process_queue = NULL;
    }
        free(scheduler);
}

void schedule_process(Scheduler* scheduler, Process process){

    if (!scheduler || !scheduler->process_queue) {
    //printf("Scheduler or process queue is NULL.\n");
    return;
    }
    
    if(!heap_insert(scheduler->process_queue, &process)){
        //printf("Failed to insert process into the scheduler queue!\n");
        return;
    }
    //printf("Process added successfully to the scheduler queue.\n");
}

Process *get_next_process(Scheduler* scheduler){

    if(!scheduler || !scheduler->process_queue){
        //printf("Schedule or pq is empty or not allocated!\n");
        return NULL;
    }
    
    if(scheduler->current_process){
        
        if(!heap_insert(scheduler->process_queue, scheduler->current_process)){
        //printf("Failed to insert process into the scheduler queue!\n");
        return NULL;
        }
        free(scheduler->current_process);
        scheduler->current_process = NULL;
    }

    Process* next_process = malloc(sizeof(Process));
    if (!heap_extract_min(scheduler->process_queue, next_process)) {
        //printf("No processes available in the queue.\n");
        free(next_process); 
        return NULL;
    }
    
    scheduler->current_process = next_process;
    next_process->is_running = true;
    return next_process;
}

void tick(Scheduler* scheduler) {

    if (!scheduler || !scheduler->current_process) {
        //printf("Scheduler is not initialized.\n");
        return;
    }

    update_vruntime(scheduler->current_process, scheduler->time_slice);
}
