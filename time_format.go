package main

import (
	"fmt"
	"log"
	"os"
	"time"
)

func main() {
	dur, err := time.ParseDuration(os.Args[1] + "s")
	if err != nil {
		log.Fatal(err)
	}
	if dur.Round(time.Second).Seconds() > 0 {
		fmt.Println(dur.Round(time.Millisecond))
	} else if dur.Round(time.Millisecond).Milliseconds() > 0 {
		fmt.Println(dur.Round(time.Millisecond))
	} else {
		fmt.Println(dur)
	}
}
