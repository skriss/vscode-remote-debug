package main

import (
	"fmt"
	"os"
	"time"
)

func main() {
	for {
		_ = os.Environ()

		fmt.Println("Hello, world!")
		time.Sleep(5 * time.Second)
	}
}
