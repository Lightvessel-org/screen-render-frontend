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

dequeue :: proc(queue: ^CommandQueue) -> (element: LedCommand, succeeded: bool) {
	if sync.mutex_try_lock(&queue.lock) {
		defer sync.mutex_unlock(&queue.lock)
		if(len(queue.queue) > 0) {
			element = pop(&queue.queue)
			succeeded = true
		} else {
			succeeded = false
		}
	} else {
		succeeded = false
	}

	return element, succeeded
}

peek :: proc(queue: ^CommandQueue) -> (element: LedCommand, succeeded: bool) {
	if sync.mutex_try_lock(&queue.lock) {
		defer sync.mutex_unlock(&queue.lock)
		size := len(queue.queue)
		if(size > 0) {
			return queue.queue[size - 1], true
			succeeded = true
		} else {
			succeeded = false
		}
	} else {
		succeeded = false
	}

	return element, succeeded
}

enqueue ::proc(queue: ^CommandQueue, command: LedCommand) {
    sync.mutex_lock(&queue.lock)
    defer sync.mutex_unlock(&queue.lock)
    append(&queue.queue, command)
	fmt.printfln("Enqueued: ", command, " TOTAL SIZE: ", len(queue.queue))
}

delete_queue :: proc(queue: ^CommandQueue) {
	delete(queue.queue)
}