import time
import numpy as np
import psutil
import datetime

def get_memory_usage():
    process = psutil.Process()
    mem_info = process.memory_info()
    return mem_info.rss / 1e6

def main():
    """
    Performs a matrix multiplication every 5 seconds and prints the progress and memory usage. Stops after 2 minutes.
    """
    start_time = time.time()
    max_runtime = 2 * 60
    end_time = start_time + max_runtime

    iteration = 0

    while time.time() < end_time:
        iteration += 1
        A = np.random.rand(5000, 5000)
        B = np.random.rand(5000, 5000)
        _ = A @ B
        
        mem_usage = get_memory_usage()
        remaining_time = int(end_time - time.time())
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        print(f"[{timestamp}] Iteration {iteration} - Remaining time: {remaining_time}s - Memory usage: {mem_usage:.2f} MB")

        time.sleep(5)

    print("Completed all iterations.")

if __name__ == "__main__":
    main()