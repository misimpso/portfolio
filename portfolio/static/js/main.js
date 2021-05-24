const tiltEffectSettings = {
    max: 5,
    perspective: 1000,
    scale: 1.05,
    speed: 500,
    easing: "cubic-bezier(.03,.98,.52,.99)"
};

const card = document.querySelector("main");

card.addEventListener("mouseenter", cardMouseEnter);
card.addEventListener("mousemove", cardMouseMove);
card.addEventListener("mouseleave", cardMouseLeave);

function cardMouseEnter(event) {
    setTransition();
}

function cardMouseMove(event) {
    const cardWidth = card.offsetWidth;
    const cardHeight = card.offsetHeight;
    const centerX = card.offsetLeft + cardWidth / 2;
    const centerY = card.offsetTop + cardHeight / 2;
    const mouseX = event.clientX - centerX;
    const mouseY = event.clientY - centerY;
    const rotateXUncapped = (tiltEffectSettings.max * mouseY / (cardHeight / 2));
    const rotateYUncapped = -1 * (tiltEffectSettings.max * mouseX / (cardWidth / 2));
    const rotateX = rotateXUncapped < -tiltEffectSettings.max ? -tiltEffectSettings.max : (rotateXUncapped > tiltEffectSettings.max ? tiltEffectSettings.max : rotateXUncapped);
    const rotateY = rotateYUncapped < -tiltEffectSettings.max ? -tiltEffectSettings.max : (rotateYUncapped > tiltEffectSettings.max ? tiltEffectSettings.max : rotateYUncapped);

    card.style.transform = `perspective(${tiltEffectSettings.perspective}px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) 
                          scale3d(${tiltEffectSettings.scale}, ${tiltEffectSettings.scale}, ${tiltEffectSettings.scale})`;
}

function cardMouseLeave(event) {
    card.style.transform = `perspective(${tiltEffectSettings.perspective}px) rotateX(0deg) rotateY(0deg) scale3d(1, 1, 1)`;
    setTransition();
}

function setTransition() {
    clearTimeout(card.transitionTimeoutId);
    card.style.transition = `transform ${tiltEffectSettings.speed}ms ${tiltEffectSettings.easing}`;
    card.transitionTimeoutId = setTimeout(() => {
        card.style.transition = "";
    }, tiltEffectSettings.speed);
}