const screenshotImg = document.getElementById('screenshotImg');
const slideCounter = document.getElementById('slideCounter');
const prevBtn = document.getElementById('prevBtn');
const nextBtn = document.getElementById('nextBtn');

const totalScreenshots = 6;
let currentSlide = 1;

function updateSlide() {
  screenshotImg.src = `screenshot_${currentSlide}.png`;
  slideCounter.textContent = `${currentSlide} / ${totalScreenshots}`;
}

prevBtn.addEventListener('click', () => {
  currentSlide = currentSlide === 1 ? totalScreenshots : currentSlide - 1;
  updateSlide();
});

nextBtn.addEventListener('click', () => {
  currentSlide = currentSlide === totalScreenshots ? 1 : currentSlide + 1;
  updateSlide();
});

updateSlide();
