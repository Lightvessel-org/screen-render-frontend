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
			fmt.printfln("DEQUEUED: ", element)
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
			element = queue.queue[size - 1]
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
	inject_at(&queue.queue, 0, command)
	fmt.printfln("INJECTED: ", command)
}

delete_queue :: proc(queue: ^CommandQueue) {
	delete(queue.queue)
}