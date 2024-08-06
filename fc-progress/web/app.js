const progressWrapper = $('.progress-wrapper');
let progressInterval;
let progressTime = 0;

// discord.gg/piotreqscripts

const startProgress = ((data) => {
    progressTime = (data.duration / 1000);
    progressWrapper.html(`
    <div class="progress-main">
        <i class="${data.icon || 'fa-solid fa-arrows-rotate'}"></i>
        <span>${data.label}</span>
        <div class="progress-time">${formatTime(progressTime)}</div>
    </div>
    <div class="progress-bar">
        <div style="width: 100%" class="bar-fill"></div>
    </div>`);
    progressWrapper.css('display', 'flex');
    setTimeout(() => {
        progressWrapper.animate({
            bottom: '2.5%',
            opacity: '1.0'
        }, 1000);
        setTimeout(() => {
            progressInterval = setInterval(() => {
                progressTime--;
                $('.progress-time').text(formatTime(progressTime));
                if (progressTime < 1) {
                    clearInterval(progressInterval);
                }
            }, 1000);
            $('.bar-fill').animate({
                width: '0%'
            }, data.duration, () => {
                $.post('https://fc-progress/FinishProgress');
                setTimeout(() => {
                    progressWrapper.animate({
                        bottom: '-25%',
                        opacity: '0.0'
                    }, 1000, () => {
                        progressWrapper.hide();
                    })
                }, 500);
            });
        }, 1000);
    }, 10);
})

const formatTime = ((time) => {
    let minutes = Math.floor(time / 60);
    let seconds = time - (minutes * 60);
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
})

window.addEventListener("message", (event) => {
    let data = event.data;
    switch(data.action) {
        case 'StartProgress':
            startProgress(data.data);
            break;
        case 'CancelProgress':
            clearInterval(progressInterval);
            $('.bar-fill').stop();
            setTimeout(() => {
                progressTime = 0;
                progressWrapper.animate({
                    bottom: '-25%',
                    opacity: '0.0'
                }, 1000, () => {
                    progressWrapper.hide();
                })
            }, 250);
            break;
    }
})