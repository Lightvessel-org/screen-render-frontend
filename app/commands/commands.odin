package commands
import "core:sync"

command_e :: enum {
    CREATE,
    DELETE,
    MODIFY,
}

LedCommand :: struct{
    type: command_e,
}

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

enqueue ::proc(queue: ^CommandQueue, command: LedCommand) {
    sync.mutex_lock(&queue.lock)
    defer sync.mutex_unlock(&queue.lock)
    append(&queue.queue, command)
}

delete_queue :: proc(queue: ^CommandQueue) {
	delete(queue.queue)
}