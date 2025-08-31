// Dice faces configuration - each array represents the dots on a face
const diceFaces = {
    1: [4], // center dot (index 4 in a 3x3 grid)
    2: [0, 8], // top-left and bottom-right
    3: [0, 4, 8], // diagonal
    4: [0, 2, 6, 8], // corners
    5: [0, 2, 4, 6, 8], // corners + center
    6: [0, 1, 2, 6, 7, 8] // two columns
};

// Current dice values
let currentDice1 = 1;
let currentDice2 = 1;

// Elements
const dice1 = document.getElementById('dice1');
const dice2 = document.getElementById('dice2');
const rollButton = document.getElementById('rollButton');
const dice1Result = document.getElementById('dice1Result');
const dice2Result = document.getElementById('dice2Result');
const totalResult = document.getElementById('totalResult');

// Initialize dice faces
function initializeDice() {
    setupDiceFace(dice1);
    setupDiceFace(dice2);
    updateDiceDisplay(dice1, 1);
    updateDiceDisplay(dice2, 1);
}

// Setup dice face structure
function setupDiceFace(diceElement) {
    const faces = ['front', 'back', 'right', 'left', 'top', 'bottom'];

    faces.forEach(faceClass => {
        const face = diceElement.querySelector(`.${faceClass}`);
        face.innerHTML = '';

        // Create 9 dot positions (3x3 grid)
        for (let i = 0; i < 9; i++) {
            const dot = document.createElement('div');
            dot.className = 'dot';
            dot.style.visibility = 'hidden';
            face.appendChild(dot);
        }
    });
}

// Update dice face to show specific number
function updateDiceDisplay(diceElement, number) {
    const faces = diceElement.querySelectorAll('.face');

    // Map numbers to faces (this creates the illusion of a real die)
    const faceNumbers = {
        front: 1,
        back: 6,
        right: 2,
        left: 5,
        top: 3,
        bottom: 4
    };

    faces.forEach(face => {
        const faceClass = Array.from(face.classList).find(cls => cls !== 'face');
        const faceNumber = faceNumbers[faceClass];
        const dots = face.querySelectorAll('.dot');

        // Hide all dots first
        dots.forEach(dot => {
            dot.style.visibility = 'hidden';
        });

        // Show dots based on the number for this face
        if (diceFaces[faceNumber]) {
            diceFaces[faceNumber].forEach(dotIndex => {
                if (dots[dotIndex]) {
                    dots[dotIndex].style.visibility = 'visible';
                }
            });
        }
    });

    // Rotate dice to show the correct face
    const rotations = {
        1: 'rotateX(0deg) rotateY(0deg)',
        2: 'rotateX(0deg) rotateY(-90deg)',
        3: 'rotateX(-90deg) rotateY(0deg)',
        4: 'rotateX(90deg) rotateY(0deg)',
        5: 'rotateX(0deg) rotateY(90deg)',
        6: 'rotateX(0deg) rotateY(180deg)'
    };

    diceElement.style.transform = rotations[number];
}

// Generate random number between 1 and 6
function rollDice() {
    return Math.floor(Math.random() * 6) + 1;
}

// Roll both dice
function rollBothDice() {
    const newDice1 = rollDice();
    const newDice2 = rollDice();

    // Disable button during animation
    rollButton.disabled = true;
    rollButton.textContent = 'Rzucanie...';

    // Add rolling animation
    dice1.classList.add('rolling');
    dice2.classList.add('rolling');

    // Update values after animation
    setTimeout(() => {
        currentDice1 = newDice1;
        currentDice2 = newDice2;

        updateDiceDisplay(dice1, currentDice1);
        updateDiceDisplay(dice2, currentDice2);
        updateResults();

        // Remove rolling class and re-enable button
        dice1.classList.remove('rolling');
        dice2.classList.remove('rolling');
        rollButton.disabled = false;
        rollButton.textContent = 'Rzuć kostkami!';
    }, 800);
}

// Update result display
function updateResults() {
    dice1Result.textContent = currentDice1;
    dice2Result.textContent = currentDice2;
    totalResult.textContent = currentDice1 + currentDice2;

    // Add a subtle animation to the results
    const resultElement = document.getElementById('result');
    resultElement.style.transform = 'scale(1.05)';
    setTimeout(() => {
        resultElement.style.transform = 'scale(1)';
    }, 200);
}

// Add keyboard support
function handleKeyPress(event) {
    if (event.code === 'Space' || event.key === 'Enter') {
        event.preventDefault();
        if (!rollButton.disabled) {
            rollBothDice();
        }
    }
}

// Event listeners
rollButton.addEventListener('click', rollBothDice);
document.addEventListener('keydown', handleKeyPress);

// Initialize the dice when page loads
document.addEventListener('DOMContentLoaded', () => {
    initializeDice();
    updateResults();

    // Add smooth transitions
    dice1.style.transition = 'transform 0.8s ease-out';
    dice2.style.transition = 'transform 0.8s ease-out';
    document.getElementById('result').style.transition = 'transform 0.2s ease-out';
});

// Add some fun sound effects (optional - can be uncommented if you add sound files)
/*
function playRollSound() {
    const audio = new Audio('roll-sound.mp3');
    audio.volume = 0.3;
    audio.play().catch(e => console.log('Sound not available'));
}
*/

// Add double click for quick roll
dice1.addEventListener('dblclick', rollBothDice);
dice2.addEventListener('dblclick', rollBothDice);

// Add touch support for mobile
dice1.addEventListener('touchstart', (e) => {
    e.preventDefault();
    if (!rollButton.disabled) {
        rollBothDice();
    }
});

dice2.addEventListener('touchstart', (e) => {
    e.preventDefault();
    if (!rollButton.disabled) {
        rollBothDice();
    }
});
