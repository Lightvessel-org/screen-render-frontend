package commands
import "core:sync"
import "core:fmt"


CommandQueue :: struct {
    lock : sync.Mutex,
    queue: [dynamic]LedCommand
}

create_queue :: proc() -> CommandQueue {
    return CommandQueue {
        lock = sync.Mutex {}
    };
}

dequeue_all :: proc(queue: ^CommandQueue) -> (elements: []LedCommand, succeeded: bool) {
	if sync.mutex_try_lock(&queue.lock) {
		defer sync.mutex_unlock(&queue.lock)

		elements = queue.queue[:]
		delete(queue.queue)

        queue.queue = make([dynamic]LedCommand)
		succeeded = true
	} else {
		succeeded = false
	}

	return elements, succeeded
}

peek :: proc(queue: ^CommandQueue){
	sync.mutex_lock(&queue.lock)
    defer sync.mutex_unlock(&queue.lock)

	fmt.printfln("Queue size: ", len(queue.queue))
}

enqueue ::proc(queue: ^CommandQueue, command: LedCommand) {
    sync.mutex_lock(&queue.lock)
    defer sync.mutex_unlock(&queue.lock)
    append(&queue.queue, command)
}

delete_queue :: proc(queue: ^CommandQueue) {
	delete(queue.queue)
}