const screenshotImg = document.getElementById('screenshotImg');
const slideCounter = document.getElementById('slideCounter');
const prevBtn = document.getElementById('prevBtn');
const nextBtn = document.getElementById('nextBtn');

const screenshots = [1, 3, 4, 5, 6]; // Skip screenshot 2
let currentIndex = 0;

function updateSlide() {
  const slideNum = screenshots[currentIndex];
  screenshotImg.src = `screenshot_${slideNum}.png`;
  slideCounter.textContent = `${currentIndex + 1} / ${screenshots.length}`;
}

prevBtn.addEventListener('click', () => {
  currentIndex = currentIndex === 0 ? screenshots.length - 1 : currentIndex - 1;
  updateSlide();
});

nextBtn.addEventListener('click', () => {
  currentIndex = currentIndex === screenshots.length - 1 ? 0 : currentIndex + 1;
  updateSlide();
});

updateSlide();
