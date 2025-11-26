#include <stddef.h>
#include "../include/min_heap.h"
#include "../include/process.h"

MinHeap* heap_create(size_t capacity, size_t element_size, int (*compare)(const void* a, const void* b)){

    MinHeap* my_heap = (MinHeap*)malloc(sizeof(MinHeap));
    
    if(my_heap == NULL) return NULL;
    
    my_heap->data = malloc(capacity * element_size);
    
    if(my_heap->data == NULL){
    
        free(my_heap->data);
        free(my_heap);
        return NULL;
    }
    
    my_heap->element_size = element_size;
    my_heap->capacity = capacity;
    my_heap->size = 0;
    my_heap->compare = compare;
    
    return my_heap;
}

void heap_destroy(MinHeap* heap){

    if (heap) {
        if (heap->data) {
            free(heap->data);
            heap->data = NULL;
        }
        free(heap);
        heap = NULL;
    }
}

int heap_insert(MinHeap* heap, const void* element){

    if(!heap) return 0;

    if(heap->size == heap->capacity){
        heap->data = realloc(heap->data, (heap->capacity * 2) * heap->element_size);
        if (!heap->data) {
        //printf("Memory allocation failed!\n");
        return 0;
        }
        
        heap->capacity = 2 * heap->capacity;
    }

    memcpy((char*)heap->data + (heap->size * heap->element_size), element, heap->element_size);
    heap->size++;

    heapify_up(heap, heap->size - 1);
    return 1;
}

/*void heapify_up(MinHeap* heap, size_t index){

    if(!heap) return;
    
    while(index > 0){

        size_t parent_index = (index - 1) / 2;

        void *curr_node = ((char*)(heap->data) + index * heap->element_size);
        void *parent_node = ((char*)(heap->data) + parent_index * heap->element_size);

        if(compare(parent_node, curr_node) > 0){
            swap(parent_node, curr_node, heap->element_size);
        }else break;
        index = parent_index;
    }
}*/

void heapify_up(MinHeap* heap, size_t index){
    
    if(!heap) return;

    while (index > 0){
        
        size_t parent_index = (index - 1)/2;
        if(heap->compare(
                (char*)heap->data + parent_index * heap->element_size,
                (char*)heap->data + index * heap->element_size) <= 0){
            break;
        }
        swap((char*)heap->data + parent_index * heap->element_size,
            (char*)heap->data + index * heap->element_size,
            heap->element_size
        );
        index = parent_index;
    }
}

void heapify_down(MinHeap* heap){
    
    if(!heap) return;

    int index = 0;
    
    while(index < heap->size){
        
        size_t left_child = 2 * index + 1;
        size_t right_child = 2 * index + 2;
        size_t smallest_child;

        if (left_child >= heap->size) break;

        if (right_child >= heap->size) {
            smallest_child = left_child;
        }else{
            
            if(heap->compare(
            (char*)heap->data + left_child * heap->element_size,
            (char*)heap->data + right_child * heap->element_size) <= 0){
                smallest_child = left_child;
            }else{
                smallest_child = right_child;
            }
        }

        if (heap->compare(
            (char*)heap->data + index * heap->element_size,
            (char*)heap->data + smallest_child * heap->element_size) <= 0) {
                break;
        }

        swap((char*)heap->data + index * heap->element_size,
            (char*)heap->data + smallest_child * heap->element_size,
            heap->element_size
        );

        index = smallest_child;
    }
}

int compare(const void* a, const void* b) {
    const Process* proc1 = (const Process*)a;
    const Process* proc2 = (const Process*)b;

    if (proc1->vruntime < proc2->vruntime) return -1; 
    if (proc1->vruntime > proc2->vruntime) return 1;  
    return 0; 
}

void swap(void* a, void* b, size_t size){

    void* temp = malloc(size);  
    if (!temp) {
        //printf("Memory allocation failed!\n");
        return;
    }

    memcpy(temp, a, size);
    memcpy(a, b, size);
    memcpy(b, temp, size);

    free(temp);
}

int heap_extract_min(MinHeap* heap, void* result){

if(!heap || heap->size <= 0){
        //printf("The heap is empty!\n");
        return 0;
    }

    memcpy((char*)result, heap->data, heap->element_size);
    void *last_element = ((heap->data) + (heap->size - 1) * heap->element_size);
    memcpy((char*)heap->data, last_element, heap->element_size);
    
    heap->size--;
    heapify_down(heap);
    return 1;
}

int heap_peek(const MinHeap* heap, void* result){

    if(!heap || heap->size == 0){
        //printf("The heap is empty!\n");
        return 0;
    }

    if(result == NULL || heap->data == NULL){
        //printf("Allocation error!\n");
        return 0;
    }
    memcpy(result, heap->data, heap->element_size);
    return 1;
}

size_t heap_size(const MinHeap* heap){
    if(heap == NULL){
        //printf("Memory allocation failed!\n");
        return 0;
    }
    return heap->size;
}

int heap_merge(MinHeap* heap1, const MinHeap* heap2){

    if(!heap1 || !heap2) return 0;
    
    //if(heap2->size == 0) return 1;

    if(heap1->element_size != heap2->element_size) return 0;

    heap1->capacity += heap2->capacity;
    void* new_data = realloc(heap1->data, heap1->capacity * heap1->element_size);
    
    if(!new_data){
        //printf("Reallocation for target heap capacity failed!\n");
        return 0;
    }
    heap1->data = new_data;

    for(int i = 0; i < heap2->size; i++){

        void* data_to_insert = ((char*)(heap2->data) + i * heap2->element_size);
        if(!heap_insert(heap1, data_to_insert)) return 0;
    }
    return 1;
}