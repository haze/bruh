package main

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
	"time"
)

func formatDuration(d time.Duration) string {
	var sb strings.Builder
	d = d.Round(time.Second)

	months := int(d / ((time.Hour * 24) * 30))
	d -= time.Duration(months) * (time.Hour * 24) * 30

	days := int(d / (time.Hour * 24))
	d -= time.Duration(days) * (time.Hour * 24)

	h := int(d / time.Hour)
	d -= time.Duration(h) * time.Hour

	m := int(d / time.Minute)
	d -= time.Duration(m) * time.Minute

	s := int(d / time.Second)
	d -= time.Duration(s) * time.Second

	if months > 0 {
		sb.WriteRune('~')
		sb.WriteString(strconv.Itoa(months))
		sb.WriteString("mo ")
	}
	if days > 0 {
		sb.WriteString(strconv.Itoa(days))
		sb.WriteString("d ")
	}
	if h > 0 {
		sb.WriteString(strconv.Itoa(h))
		sb.WriteString("h ")
	}
	if m > 0 {
		sb.WriteString(strconv.Itoa(m))
		sb.WriteString("m ")
	}
	if s > 0 {
		sb.WriteString(strconv.Itoa(s))
		sb.WriteString("s ")
	}
	return strings.TrimSpace(sb.String())
}

func main() {
	astr := os.Args[1]
	bstr := os.Args[2]
	a, err := strconv.ParseInt(astr, 10, 64)
	if err != nil {
		log.Fatal(err)
	}
	b, err := strconv.ParseInt(bstr, 10, 64)
	if err != nil {
		log.Fatal(err)
	}
	var newer, older int64
	if b > a {
		newer = a
		older = b
	} else {
		newer = b
		older = a
	}
	diff := time.Unix(older, 0).Sub(time.Unix(newer, 0))
	fmt.Println(formatDuration(diff))
}
