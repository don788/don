package main
import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"sync"
)

func downloadFile(url string, destination string, wg *sync.WaitGroup, ch chan bool) {
	defer wg.Done()

	// 创建输出文件
	file, err := os.Create(destination)
	if err != nil {
		fmt.Printf("Failed to create file: %v\n", err)
		return
	}
	defer file.Close()

	// 发起HTTP GET请求
	response, err := http.Get(url)
	if err != nil {
		fmt.Printf("Failed to download file: %v\n", err)
		return
	}
	defer response.Body.Close()

	// 检查HTTP状态码
	if response.StatusCode != http.StatusOK {
		fmt.Printf("Failed to download file, status code: %d\n", response.StatusCode)
		return
	}

	// 将响应体内容写入文件
	_, err = io.Copy(file, response.Body)
	if err != nil {
		fmt.Printf("Failed to write to file: %v\n", err)
		return
	}

	fmt.Printf("Downloaded file: %s\n", destination)
	<-ch // 从信道中释放一个位置，表示下载完成
}

func main() {
	// 读取文件中的URL
	urlFile := "english.txt"
	urls, err := readURLsFromFile(urlFile)
	if err != nil {
		fmt.Printf("Failed to read URLs from file: %v\n", err)
		return
	}

	// 创建目录用于存储下载的文件
	downloadDir := "downloads"
	err = os.MkdirAll(downloadDir, os.ModePerm)
	if err != nil {
		fmt.Printf("Failed to create download directory: %v\n", err)
		return
	}

	// 设置并发下载的最大数量
	maxConcurrentDownloads := 10
	concurrentDownloads := make(chan bool, maxConcurrentDownloads)

	var wg sync.WaitGroup
	// 启动并发下载任务
	for _, url := range urls {
		wg.Add(1)
		filename := filepath.Base(url)
		destination := filepath.Join(downloadDir, filename)
		concurrentDownloads <- true // 从信道中获取一个位置，表示开始下载
		go downloadFile(url, destination, &wg, concurrentDownloads)
	}

	// 等待所有下载任务完成
	wg.Wait()
}

func readURLsFromFile(filePath string) ([]string, error) {
	file, err := os.Open(filePath)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	var urls []string
	var line string
	for {
		_, err := fmt.Fscanf(file, "%s\n", &line)
		if err != nil {
			if err == io.EOF {
				break
			}
			return nil, err
		}
		urls = append(urls, line)
	}

	return urls, nil
}

