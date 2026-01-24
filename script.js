// Dice faces configuration - Mapping dots on a 3x3 grid (indices 0-8)
const diceFaces = {
    1: [4],                // Center
    2: [0, 8],             // Top-Left, Bottom-Right
    3: [0, 4, 8],          // Diagonal
    4: [0, 2, 6, 8],       // Corners
    5: [0, 2, 4, 6, 8],    // Corners + Center
    6: [0, 2, 3, 5, 6, 8]  // Columns (Left: 0,3,6 | Right: 2,5,8)
};

// Elements
const diceContainer = document.querySelector('.dice-container');
const diceCountSelect = document.getElementById('diceCount');
const rollButton = document.getElementById('rollButton');
const historyList = document.getElementById('historyList');
const resultContainer = document.getElementById('result');

// Initialize
function initializeApp() {
    createDice(2); // Default
    resultContainer.innerHTML = '<div class="total">Gotowy do rzutu</div>';
}

// Create dice HTML dynamically
function createDice(count) {
    diceContainer.innerHTML = '';
    
    for (let i = 0; i < count; i++) {
        const dice = document.createElement('div');
        dice.className = 'dice';
        dice.id = `dice${i+1}`;
        
        ['front', 'back', 'right', 'left', 'top', 'bottom'].forEach(faceType => {
            const face = document.createElement('div');
            face.className = `face ${faceType}`;
            
            // Create 9 dots
            for(let j=0; j<9; j++) {
                const dot = document.createElement('div');
                dot.className = 'dot';
                face.appendChild(dot);
            }
            dice.appendChild(face);
        });
        
        diceContainer.appendChild(dice);
        
        // Initial animation/position
        updateDiceDisplay(dice, 1);
    }
}

// Update single dice display
function updateDiceDisplay(diceElement, number) {
    const faces = diceElement.querySelectorAll('.face');

    // Map numbers to faces
    const faceNumbers = {
        front: 1, back: 6, right: 2, left: 5, top: 3, bottom: 4
    };

    faces.forEach(face => {
        const faceClass = Array.from(face.classList).find(cls => cls !== 'face');
        const faceNumber = faceNumbers[faceClass];
        const dots = face.querySelectorAll('.dot');

        // Reset all dots to hidden
        dots.forEach(dot => dot.style.opacity = '0');

        // Show specific dots for this number
        if (diceFaces[faceNumber]) {
            diceFaces[faceNumber].forEach(dotIndex => {
                if (dots[dotIndex]) {
                    dots[dotIndex].style.opacity = '1';
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

// Generate random number
function rollDice() {
    const array = new Uint32Array(1);
    self.crypto.getRandomValues(array);
    return (array[0] % 6) + 1;
}

// Roll logic for N dice
function rollAllDice() {
    const count = parseInt(diceCountSelect.value);
    const results = [];
    
    rollButton.disabled = true;
    rollButton.textContent = 'Rzucanie...';
    
    // Add animation to all
    const allDice = document.querySelectorAll('.dice');
    allDice.forEach(d => d.classList.add('rolling'));
    
    // Generate results
    for(let i=0; i<count; i++) {
        results.push(rollDice());
    }
    
    setTimeout(() => {
        let total = 0;
        allDice.forEach((dice, index) => {
            const val = results[index];
            total += val;
            updateDiceDisplay(dice, val);
            dice.classList.remove('rolling');
        });
        
        // Update text result
        let resultText = results.map((r, i) => `K${i+1}: ${r}`).join(' | ');
        const resultHTML = `
            <div class="dice-result" style="flex-wrap: wrap; justify-content: center;">${resultText}</div>
            <div class="total">Suma: ${total}</div>
        `;
        resultContainer.innerHTML = resultHTML;
        
        addToHistory(results);
        
        rollButton.disabled = false;
        rollButton.textContent = 'Rzuć kostkami!';
        
        // Pulse animation
        resultContainer.style.transform = 'scale(1.05)';
        setTimeout(() => resultContainer.style.transform = 'scale(1)', 200);
        
    }, 800);
}

// Update history for N dice
function addToHistory(results) {
    const total = results.reduce((a, b) => a + b, 0);
    const time = new Date().toLocaleTimeString('pl-PL', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
    
    const item = document.createElement('li');
    item.className = 'history-item';
    
    // Format: 1, 3, 5 = 9
    const rollsStr = results.join(' + ');
    
    item.innerHTML = `
        <span class="roll-time" style="font-size: 0.8rem; color: #ddd;">${time}</span>
        <div style="text-align: right;">
            <span style="display:block; font-size: 0.85rem;">🎲 ${rollsStr}</span>
            <span class="roll-number">= ${total}</span>
        </div>
    `;

    if (historyList.firstChild) {
        historyList.insertBefore(item, historyList.firstChild);
    } else {
        historyList.appendChild(item);
    }
    
    if (historyList.children.length > 10) historyList.removeChild(historyList.lastChild);
}

// Event Listeners
rollButton.addEventListener('click', rollAllDice);

diceCountSelect.addEventListener('change', (e) => {
    createDice(parseInt(e.target.value));
    resultContainer.innerHTML = '<div class="total">Gotowy do rzutu</div>';
});

// Keyboard
document.addEventListener('keydown', (e) => {
    if ((e.code === 'Space' || e.key === 'Enter') && !rollButton.disabled) {
        e.preventDefault();
        rollAllDice();
    }
});

// Init
document.addEventListener('DOMContentLoaded', initializeApp);

// Double click
document.addEventListener('dblclick', (e) => {
    if(e.target.closest('.dice') && !rollButton.disabled) {
        rollAllDice();
    }
});
// Touch
document.addEventListener('touchstart', (e) => {
    if(e.target.closest('.dice') && !rollButton.disabled) {
        e.preventDefault();
        rollAllDice();
    }
});
