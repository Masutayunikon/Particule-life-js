<template>
  <main class="w-full h-full">
    <canvas ref="canvas" id="canvas" class="w-screen h-screen">
      Your browser does not support the HTML5 canvas tag.
    </canvas>
    <span class="text-white text-xl absolute bottom-4 left-4">{{ mousePos.x }} || {{ mousePos.y }}</span>
    <span class="text-white text-xl absolute bottom-4 right-4">{{ particles.length }}</span>
    <div class="absolute top-4 right-4 flex flex-col">
      <Icon id="settings" name="mdi:settings" @click="settingsIsOpen = !settingsIsOpen" class="z-10" color="white" size="2rem"/>
      <Icon :name="pause ? 'mdi:play' : 'mdi:pause'" class="z-10" @click="setPause" :color="pause ? 'green' : 'red'" size="2rem"/>
      <Icon name="game-icons:perspective-dice-six-faces-random" color="white" size="2rem" @click="generateMatrix"/>
      <Icon name="mdi:refresh" color="white" size="2rem" @click="reset"/>
      <Icon name="material-symbols:brush" size="2rem" @click="pencilIsInUse = !pencilIsInUse" :color="pencilIsInUse ? 'green' : 'red'"/>
      <Icon name="mdi:delete" size="2rem" @click="deleteAllParticles" color="red"/>
    </div>
    <dialog v-if="settingsIsOpen" class="absolute top-0 left-0 w-full h-full bg-transparent flex justify-center items-center">
      <div class="w-9/12 h-3/4 overflow-auto rounded-3xl scrollbar-hide bg-gray-900">
        <div class="p-5 flex w-full flex-wrap">
          <button @click="settingsPanelPage = 0" :class="[settingsPanelPage === 0 ? 'bg-gray-800' : 'bg-gray-600']" class="rounded-2xl border-2 border-gray-500 text-white p-3 hover:bg-gray-700 active:bg-gray-800 mr-5">Attraction</button>
          <button @click="settingsPanelPage = 1" :class="[settingsPanelPage === 1 ? 'bg-gray-800' : 'bg-gray-600']" class="rounded-2xl border-2 border-gray-500 text-white p-3 hover:bg-gray-700 active:bg-gray-800 mr-5">Particles</button>
          <button @click="settingsPanelPage = 2" :class="[settingsPanelPage === 2 ? 'bg-gray-800' : 'bg-gray-600']" class="rounded-2xl border-2 border-gray-500 text-white p-3 hover:bg-gray-700 active:bg-gray-800 mr-5">Parameters</button>
          <button @click="settingsPanelPage = 3" :class="[settingsPanelPage === 3 ? 'bg-gray-800' : 'bg-gray-600']" class="rounded-2xl border-2 border-gray-500 text-white p-3 hover:bg-gray-700 active:bg-gray-800 mr-5">Pencil</button>
          <Icon id="settings" name="mdi:close" @click="settingsIsOpen = false" class="ml-auto" color="white " size="2rem"/>
        </div>
        <div v-if="settingsPanelPage === 0" class="w-full p-5 flex flex-col overflow-auto scroll-auto">
          <div class="flex mb-8">
            <div>
              <Icon name="mdi:mouse-scroll-wheel" size="2rem" color="white"/>
              <span class="ml-2 text-xl text-white">Wheel click to set to 0</span>
            </div>
            <div class="ml-5">
              <Icon name="mdi:mouse-left-click" size="2rem" color="white"/>
              <span class="ml-2 text-xl text-white">Left click to increase</span>
            </div>
            <div class="ml-5">
              <Icon name="mdi:mouse-right-click" size="2rem" color="white"/>
              <span class="ml-2 text-xl text-white">Right click to decrease</span>
            </div>
          </div>
          <div class="flex mb-8 items-center">
            <span class="text-xl text-white">Increment: </span>
            <input type="number" v-model="increment" class="w-20 h-10 bg-gray-800 text-white text-xl border-2 border-gray-500 p-2 ml-2" step="0.01" min="0" max="1"/>
            <!-- button set all to 0 to -1 and 1 -->
            <button @click="setMatrixToValue(0)" class="ml-5 bg-gray-600 text-white p-2 rounded-2xl hover:bg-gray-700 active:bg-gray-800 border-2 border-gray-500">Set all to 0</button>
            <button @click="setMatrixToValue(1)" class="ml-5 bg-gray-600 text-white p-2 rounded-2xl hover:bg-gray-700 active:bg-gray-800 border-2 border-gray-500">Set all to 1</button>
            <button @click="setMatrixToValue(-1)" class="ml-5 bg-gray-600 text-white p-2 rounded-2xl hover:bg-gray-700 active:bg-gray-800 border-2 border-gray-500">Set all to -1</button>
            <!-- button to generate random matrix with an Icon dice game-icons:perspective-dice-six-faces-random -->
            <button @click="generateMatrix" class="m-5 bg-gray-600 text-white p-2 hover:bg-gray-700 active:bg-gray-800 border-2 border-gray-500 rounded-2xl">
              <Icon name="game-icons:perspective-dice-six-faces-random" color="white"/>
            </button>
          </div>
          <div class=" flex">
            <div class="flex flex-col">
              <div class="w-16 h-16 border-2 border-black border-solid">
                <Icon  name="mdi:matrix" color="white" size="100%"/>
              </div>
              <div v-for="(atom, index) in atomsTypes" :key="index" class="w-16 h-16 border-b-2 border-l-2 border-r-2 border-black border-solid" :style="{ backgroundColor: atom.color }"></div>
            </div>
            <div v-for="(atom, index) in atomsTypes" :key="index" class="flex flex-col">
              <div class="w-16 h-16 border-b-2 border-r-2 border-black border-solid" :style="{ backgroundColor: atom.color }"></div>
              <!-- if the div is the last on add border to right -->
              <div class="w-16 h-16 border-b-2 border-r-2 border-black border-solid flex justify-center items-center hover:cursor-pointer select-none" v-for="(atom2, index2) in atomsTypes" :key="`${index}-${index2}`" :style="{ backgroundColor: getColorForValue(attractionMatrix[index][index2]) }" @mousedown="handleCellClick($event, index, index2)" @contextmenu.prevent="true">
                {{ attractionMatrix[index][index2] }}
              </div>
            </div>
          </div>
        </div>
        <div v-else-if="settingsPanelPage === 1" class="w-full p-5 flex flex-col overflow-auto scroll-auto">
          <div class="flex flex-wrap">
            <div v-for="(atom, index) in atomsTypes" :key="index" class="flex flex-col items-center w-32 h-32 m-2">
              <div class="w-16 h-16 border-2 border-black border-solid" :style="{ backgroundColor: atom.color }">
                <button @click="deleteType(index)" class="w-full h-full">
                  <Icon name="mdi:delete" color="red" size="100%" class="hover:cursor-pointer"/>
                </button>
              </div>
            </div>
            <div class="flex flex-col items-center w-32 h-32 m-2">
              <Icon name="mdi:plus" @click="createNewTypeIsOpen = true" class="w-16 h-16 border-2 border-black border-solid" color="white" size="100%"/>
            </div>
          </div>
        </div>
        <dialog v-if="createNewTypeIsOpen" class="absolute top-0 left-0 w-full h-full bg-transparent flex justify-center items-center">
          <div class="w-2/6 overflow-auto rounded-3xl scrollbar-hide bg-gray-950">
            <div class="p-5 flex w-full flex-wrap">
              <Icon id="settings" name="mdi:close" @click="createNewTypeIsOpen = false" class="ml-auto" color="white " size="2rem"/>
            </div>
            <div class="w-full p-5 flex flex-col overflow-auto scroll-auto">
              <div class="flex flex-col items-center">
                <input type="color" v-model="newTypeColor" class="w-32 h-32"/>
                <button @click="createNewType(newTypeColor)" class="w-32 h-10 bg-gray-600 text-white p-2 rounded-2xl hover:bg-gray-700 active:bg-gray-800 border-2 border-gray-500">Create</button>
              </div>
            </div>
          </div>
        </dialog>
        <div v-if="settingsPanelPage === 2" class="w-full p-5 flex flex-col overflow-auto scroll-auto">
          <div class="flex flex-col">
            <div class="flex items-center">
              <span class="text-xl text-white">Particles: </span>
              <input type="number" v-model="n" class="w-20 h-10 bg-gray-800 text-white text-xl border-2 border-gray-500 p-2 ml-2" step="1" min="1"/>
            </div>
            <div class="flex items-center">
              <span class="text-xl text-white">dt: </span>
              <input type="number" v-model="dt" class="w-20 h-10 bg-gray-800 text-white text-xl border-2 border-gray-500 p-2 ml-2" step="0.01" min="0" max="1"/>
            </div>
            <div class="flex items-center">
              <span class="text-xl text-white">Frictional Half Life: </span>
              <input type="number" v-model="frictionalHalfLife" class="w-20 h-10 bg-gray-800 text-white text-xl border-2 border-gray-500 p-2 ml-2" step="0.01" min="0" max="1"/>
            </div>
            <div class="flex items-center">
              <span class="text-xl text-white">rMax: </span>
              <input type="number" v-model="rMax" class="w-20 h-10 bg-gray-800 text-white text-xl border-2 border-gray-500 p-2 ml-2" step="0.01" min="0" max="0.4"/>
            </div>
            <div class="flex items-center">
              <span class="text-xl text-white">Screen Ratio: </span>
              <input type="number" v-model="screenRatio" class="w-20 h-10 bg-gray-800 text-white text-xl border-2 border-gray-500 p-2 ml-2" step="1" min="1" max="10"/>
            </div>
          </div>
        </div>
        <div v-if="settingsPanelPage === 3" class="w-full p-5 flex flex-col overflow-auto scroll-auto">
          <div class="flex items-center">
            <span class="text-xl text-white">Radius: </span>
            <input type="number" v-model="pencilRadius" class="w-20 h-10 bg-gray-800 text-white text-xl border-2 border-gray-500 p-2 ml-2" step="0.01" min="0" max="1"/>
          </div>
          <div class="flex items center">
            <span class="text-xl text-white">Strength: </span>
            <input type="number" v-model="pencilStrength" class="w-20 h-10 bg-gray-800 text-white text-xl border-2 border-gray-500 p-2 ml-2" step="0.01" min="0" max="1"/>
          </div>
          <div class="flex items-center">
            <span class="text-xl text-white">Color: </span>
            <div v-for="(atom, index) in atomsTypes" :key="index" class="w-16 h-16 border-2 border-black border-solid" :style="{ backgroundColor: atom.color }">
              <button @click="pencilAtomType = atom" class="w-full h-full">
                <Icon name="mdi:check" color="green" size="100%" v-if="pencilAtomType === atom"/>
              </button>
            </div>
          </div>
        </div>
      </div>
    </dialog>
  </main>
</template>

<script setup lang="ts">
/**
 * @name index.vue
 * @description Particle simulation
 *
 * Quentin ROBERT
 */

/*
  This is the variables used to change the state of the app
  1. pause: boolean to pause the simulation
  2. settingsIsOpen: boolean to open the settings panel
  3. createNewTypeIsOpen: boolean to open the create new type panel
  4. canvas: ref to the canvas element
  5. settingsPanelPage: number to change the settings panel page
  6. increment: number to change the increment value for the matrix
  7. newTypeColor: string to change the color of the new type of particle added
  8. screenRatio: number to change the screen ratio of the canvas
 */
const pause = ref(false);
const settingsIsOpen = ref(false);
const createNewTypeIsOpen = ref(false);
const canvas = ref<HTMLCanvasElement | null>(null);
const settingsPanelPage = ref(0);
const increment = ref<number>(0.01);
const newTypeColor = ref<ColorValueHex>('#FF0000');
const screenRatio = ref<number>(1);


/*
  This is the variables used as parameters for the simulation
  1. attractionMatrix: number[][] to store the attraction matrix between the particles
  2. particles: Atom[] to store the particles
  3. n: number to store the number of particles when the simulation starts or reset
  4. dt: number to store the time step for the simulation
  5. frictionalHalfLife: number to store the frictional half life for the simulation
  6. rMax: number to store the max interaction radius for the simulation
  7. forceFactor: number to store the force factor for the simulation
  8. frictionFactor: number to store the friction factor for the simulation
 */
const attractionMatrix = ref<number[][]>([]);
let particles: Atom[] = [];
const n = ref<number>(500);
const dt = ref<number>(0.02);
const frictionalHalfLife = ref<number>(0.04);
const rMax = ref<number>(0.1);
const forceFactor = 10;
const frictionFactor = ref<number>(Math.pow(0.5, dt.value / frictionalHalfLife.value));

/*
  This is the variables used for the pencil tool
  1. pencilRadius: number to store the radius of the pencil
  2. pencilStrength: number to store the strength of the pencil
  3. pencilAtomType: AtomType to store the type of the pencil
  4. pencilIsInUse: boolean to store if the pencil is in use
  5. mousePos: { x: number, y: number } to store the position of the mouse
 */
const pencilRadius = ref<number>(0.1);
const pencilStrength = ref<number>(1);
const pencilAtomType = ref<AtomType>({ color: '#FF0000' });
const pencilIsInUse = ref(false);
const mousePos = ref({ x: 0, y: 0 });

/*
  This is the watch for the variables used as parameters for the simulation
  1. watch for the dt and frictionalHalfLife to update the frictionFactor
  2. watch for the n to add or remove particles
  3. watch for the screenRatio to update the canvas width and height

  watch is used to watch the value of a ref or reactive object and run a callback when the value changes.
 */
watch([dt, frictionalHalfLife], () => {
  frictionFactor.value = Math.pow(0.5, dt.value / frictionalHalfLife.value);
});

watch(n, () => {
  if (n.value > particles.length) {
    const typesLength = atomsTypes.value.length;
    for (let i = 0; i < n.value - particles.length; i++) {
      const index = Math.floor(Math.random() * typesLength);
      const particle: Atom = {
        position: { x: Math.random(), y: Math.random() },
        velocity: { x: 0, y: 0 },
        type: atomsTypes.value[index],
        typeIndex: index,
      };

      particles.push(particle);

      const xIndex = Math.floor(particle.position.x / gridSize);
      const yIndex = Math.floor(particle.position.y / gridSize);
      grid[xIndex][yIndex].push(particle);
    }
  } else if (n.value < particles.length) {
    particles.splice(n.value, particles.length - n.value);
  }
});

watch(screenRatio, () => {
  if (canvas.value) {
    canvas.value.width = window.innerWidth / screenRatio.value;
    canvas.value.height = window.innerHeight / screenRatio.value;
  }
});


/*
  This is the variables used for the grid
  1. gridSize: number to store the size of the grid
  2. gridWidth: number to store the width of the grid
  3. grid: Atom[][][] to store the grid
 */
const gridSize = rMax.value;
const gridWidth = Math.ceil(1 / gridSize);
let grid: Atom[][][] = Array.from({ length: gridWidth }, () =>
    Array.from({ length: gridWidth }, () => [])
);


/*
  This function is used to pause the simulation
 */
const setPause = () => {
  pause.value = !pause.value;
  if (!pause.value) loop();
};

/*
  This function is used to generate the matrix of attraction between the particles randomly
 */
const generateMatrix = () => {
  const length = atomsTypes.value.length;
  attractionMatrix.value = Array.from({ length }, () =>
      Array.from({ length }, () => Math.round((Math.random() * 2 - 1) * 100) / 100)
  );
};


/*
  This function is used to generate the particles randomly
 */
const generateParticles = () => {
  particles = [];
  grid = Array.from({ length: gridWidth }, () =>
      Array.from({ length: gridWidth }, () => [])
  );

  const typesLength = atomsTypes.value.length;
  for (let i = 0; i < n.value; i++) {
    const index = Math.floor(Math.random() * typesLength);
    const particle: Atom = {
      position: { x: Math.random(), y: Math.random() },
      velocity: { x: 0, y: 0 },
      type: atomsTypes.value[index],
      typeIndex: index,
    };

    particles.push(particle);

    // Assign to grid
    const xIndex = Math.floor(particle.position.x / gridSize);
    const yIndex = Math.floor(particle.position.y / gridSize);
    grid[xIndex][yIndex].push(particle);
  }

};

/*
  This just type for the color value hex but is not really checked goodly
 */
type ColorValueHex = `#${string}`;

/*
  This is the interface for the atom type
  1. color: ColorValueHex to store the color of the atom type
 */
interface AtomType {
  color: ColorValueHex;
}

/*
  This is the interface for the atom
  1. position: { x: number, y: number } to store the position of the atom
  2. velocity: { x: number, y: number } to store the velocity of the atom
  3. type: AtomType to store the type of the atom
  4. typeIndex: number to store the index of the type of the atom
 */
interface Atom {
  position: { x: number; y: number; };
  velocity: { x: number; y: number; };
  type: AtomType;
  typeIndex: number;
}

/*
  This is the default value for the atomsTypes used to store the types of the particles
 */
const atomsTypes = ref<AtomType[]>([
  { color: '#FF0000' }, { color: '#00FF00' }, { color: '#0000FF' },
  { color: '#FFFF00' }, { color: '#00FFFF' }, { color: '#FF00FF' },
]);

/*
  This is the default value for the pencilAtomType used to store the type of the pencil
 */
pencilAtomType.value = atomsTypes.value[0];


/*
  This function is used to get the color for the value for the matrix of attraction
  @param value: number to store the value of the matrix
 */
function getColorForValue(value: number) {
  const normalized = (value + 1) / 2;
  const red = Math.floor((1 - normalized) * 255);
  const green = Math.floor(normalized * 255);
  return `rgb(${red}, ${green}, 0)`;
}


/*
  This function is used to handle the cell click for the matrix of attraction to increase or decrease the value
  @param event: MouseEvent to store the event
  @param rowIndex: number to store the row index of the matrix
  @param colIndex: number to store the column index of the matrix
 */
function handleCellClick(event: MouseEvent, rowIndex: number, colIndex: number) {
  const incrementValue = event.button === 2 ? -increment.value : increment.value;
  const newValue = Math.round((attractionMatrix.value[rowIndex][colIndex] + (event.button === 1 ? 0 : incrementValue)) * 100) / 100;
  attractionMatrix.value[rowIndex][colIndex] = Math.max(-1, Math.min(1, newValue));
  if (event.button === 1) event.preventDefault();
  attractionMatrix.value = [...attractionMatrix.value]; // Trigger reactivity
}

/*
  This function is used to set the matrix to a value
  @param value: number to store the value to set the matrix to
 */
function setMatrixToValue(value: number) {
  attractionMatrix.value = attractionMatrix.value.map(row => row.map(() => value));
}

/*
  This function is used to delete a type of particle
  @param index: number to store the index of the type of the particle
 */
function deleteType(index: number) {

  atomsTypes.value.splice(index, 1);
  attractionMatrix.value.forEach(row => row.splice(index, 1));

  attractionMatrix.value.splice(index, 1);

  attractionMatrix.value = attractionMatrix.value.map(row => row.map(value => value > index ? value - 1 : value));
  particles.forEach(particle => {
    if (particle.typeIndex > index) {
      particle.typeIndex--;
    } else if (particle.typeIndex === index) {
      particle.typeIndex = Math.floor(Math.random() * atomsTypes.value.length);
    }
  });

}

/*
  This function is used to delete all the particles (clear the simulation)
 */
function deleteAllParticles() {

  particles = [];
  grid = Array.from({ length: gridWidth }, () =>
      Array.from({ length: gridWidth }, () => [])
  );

}

/*
  This function is used to create a new type of particle
  @param color: ColorValueHex to store the color of the new type of particle
 */
function createNewType(color: ColorValueHex) {

  atomsTypes.value.push({ color });
  const length = atomsTypes.value.length;
  attractionMatrix.value = attractionMatrix.value.map(row => [...row, 0]);
  attractionMatrix.value.push(Array.from({ length }, () => 0));

  particles.forEach(particle => {
    particle.typeIndex = Math.floor(Math.random() * atomsTypes.value.length);
  });

  createNewTypeIsOpen.value = false;

}


/*
  This variable is used to store the value of the force to avoid recalculating it for better performance
 */
const usedForce = new Map<string, number>();

/*
  This function is used to quantize the value
  @param value: number to store the value to quantize
  @param precision: number to store the precision to quantize the value
 */
function quantize(value: number, precision: number) {
  return Math.round(value / precision) * precision;
}

/*
  This function is used to calculate the force between the particles
  @param r: number to store the distance between the particles
  @param a: number to store the attraction between the particles
 */
function force(r: number, a: number) {
  const quantizedR = quantize(r, 0.01);
  const quantizedA = quantize(a, 0.1);
  const key = `${quantizedR}-${quantizedA}`;
  if (!usedForce.has(key)) {
    let res = 0, beta = 0.3;
    if (r < beta) {
      res = r / beta - 1;
    } else if (beta < r && r < 1) {
      res = a * (1 - Math.abs(2 * r - 1 - beta) / (1 - beta));
    }
    usedForce.set(key, res);
    return res;
  }
  return usedForce.get(key);
}

/*
  This function is used to adjust the value for the wrap around conditions
  @param d: number to store the value to adjust
  @param dimensionSize: number to store the size of the dimension
 */
const adjustForWrapAround = (d: number, dimensionSize: number) => {
  if (d > dimensionSize / 2) d -= dimensionSize;
  else if (d < -dimensionSize / 2) d += dimensionSize;
  return d;
};

/*
  This function is used to update the particles
 */
function updateParticles() {
  grid = Array.from({ length: gridWidth }, () =>
      Array.from({ length: gridWidth }, () => [])
  );

  particles.forEach(particle => {
    // Wrap-around for particle positions
    particle.position.x = (particle.position.x + 1) % 1;
    particle.position.y = (particle.position.y + 1) % 1;

    const xIndex = Math.floor(particle.position.x / gridSize);
    const yIndex = Math.floor(particle.position.y / gridSize);
    grid[xIndex][yIndex].push(particle);
  });

  particles.forEach((particle, i) => {
    let totalForceX = 0, totalForceY = 0;
    const xIndex = Math.floor(particle.position.x / gridSize);
    const yIndex = Math.floor(particle.position.y / gridSize);

    for (let xOffset = -1; xOffset <= 1; xOffset++) {
      for (let yOffset = -1; yOffset <= 1; yOffset++) {
        const xCell = (xIndex + xOffset + gridWidth) % gridWidth;
        const yCell = (yIndex + yOffset + gridWidth) % gridWidth;

        grid[xCell][yCell].forEach(otherParticle => {
          if (particle !== otherParticle) {
            let dx = otherParticle.position.x - particle.position.x;
            let dy = otherParticle.position.y - particle.position.y;

            // Adjust for wrap-around conditions
            dx = adjustForWrapAround(dx, 1);
            dy = adjustForWrapAround(dy, 1);

            const r = Math.hypot(dx, dy);
            if (r > 0 && r < rMax.value) {
              const attraction = attractionMatrix.value[particle.typeIndex][otherParticle.typeIndex];
              const f = force(r / rMax.value, attraction) || 1;
              totalForceX += dx / r * f;
              totalForceY += dy / r * f;

              totalForceX *= rMax.value * forceFactor;
              totalForceY *= rMax.value * forceFactor;
            }
          }
        });
      }
    }

    particle.velocity.x = ((particle.velocity.x + totalForceX * dt.value) * frictionFactor.value);
    particle.velocity.y = (particle.velocity.y + totalForceY * dt.value) * frictionFactor.value;

    particle.position.x = (particle.position.x + particle.velocity.x * dt.value + 1) % 1;
    particle.position.y = (particle.position.y + particle.velocity.y * dt.value + 1) % 1;
  });
}

/*
  This function is used to get the mouse position
  @param canvas: HTMLCanvasElement to store the canvas
  @param evt: Event to store the event
 */
function getMousePos(canvas: HTMLCanvasElement, evt: Event) {
  let rect = canvas.getBoundingClientRect();
  return {
    x: (evt as MouseEvent).clientX - rect.left,
    y: (evt as MouseEvent).clientY - rect.top
  };
}

/*
  This function is the main loop for the simulation
 */
function loop() {

  if (!pause.value) {
    updateParticles();
  }

  if (canvas.value) {
    const ctx = canvas.value.getContext('2d');
    if (ctx) {
      // clear the canvas
      ctx.clearRect(0, 0, canvas.value.width, canvas.value.height);
      // set background to black
      ctx.fillStyle = 'black';
      ctx.fillRect(0, 0, canvas.value.width, canvas.value.height);
      particles.forEach(particle => {
        ctx.beginPath();
        const screenX = particle.position.x * canvas.value.width;
        const screenY = particle.position.y * canvas.value.height;
        ctx.arc(screenX, screenY, 1, 0, 2 * Math.PI);
        ctx.fillStyle = atomsTypes.value[particle.typeIndex].color;
        ctx.fill();
      });

      if (pencilIsInUse.value) {

        ctx.beginPath();

        // draw arc with canvas width and height for x and y
        ctx.arc(mousePos.value.x / screenRatio.value, mousePos.value.y / screenRatio.value, pencilRadius.value, 0, 2 * Math.PI);

        ctx.fillStyle = pencilAtomType.value.color;
        ctx.fill();
      }
    }
  }

  requestAnimationFrame(loop);

}

onMounted(() => {
  if (canvas.value) {
    /*
      Set the canvas width and height to the window width and height
      And launch the simulation
     */
    canvas.value.width = window.innerWidth / screenRatio.value;
    canvas.value.height = window.innerHeight / screenRatio.value;
    generateMatrix();
    generateParticles();
    requestAnimationFrame(loop);

    /*
       Add event listener for the mouse move and mouse down
     */
    canvas.value.addEventListener('mousemove', (evt) => {
      const ctx = canvas.value?.getContext('2d');
      mousePos.value.x = (evt as MouseEvent).clientX - ctx?.canvas.offsetLeft || 0;
      mousePos.value.y = (evt as MouseEvent).clientY - ctx?.canvas.offsetTop || 0;
    });

    /*
      Add event listener for the mouse down
     */
    canvas.value.addEventListener('mousedown', (evt) => {
      if (pencilIsInUse.value) {
        const ctx = canvas.value?.getContext('2d');
        const x = (evt as MouseEvent).clientX - ctx?.canvas.offsetLeft || 0;
        const y = (evt as MouseEvent).clientY - ctx?.canvas.offsetTop || 0;
        const particlesToAdd = pencilStrength.value;
        for (let i = 0; i < particlesToAdd; i++) {
          const particle: Atom = {
            position: { x: (x + Math.random() * pencilRadius.value * 2 - pencilRadius.value) / canvas.value.width / screenRatio.value, y: (y + Math.random() * pencilRadius.value * 2 - pencilRadius.value) / canvas.value.height / screenRatio.value },
            velocity: { x: 0, y: 0 },
            type: pencilAtomType.value,
            typeIndex: atomsTypes.value.indexOf(pencilAtomType.value),
          };
          particles.push(particle);
        }
      }
    });

  }
});

/*
  This function is used to reset the simulation
 */
function reset() {
  pause.value = true;

  generateParticles();

  if (canvas.value) {
    const ctx = canvas.value.getContext('2d');
    if (ctx) {
      ctx.clearRect(0, 0, canvas.value.width, canvas.value.height);
      ctx.fillStyle = 'black';
      ctx.fillRect(0, 0, canvas.value.width, canvas.value.height);
      particles.forEach(particle => {
        ctx.beginPath();
        const screenX = particle.position.x * canvas.value.width;
        const screenY = particle.position.y * canvas.value.height;
        ctx.arc(screenX, screenY, 1, 0, 2 * Math.PI);
        ctx.fillStyle = atomsTypes.value[particle.typeIndex].color;
        ctx.fill();
      });
    }
  }

  pause.value = false;

}

/*
  This function is used to clear the canvas when the component is unmounted
 */
onBeforeUnmount(() => {
  if (canvas.value) {
    pause.value = true;
    const ctx = canvas.value.getContext('2d');
    if (ctx) {
      ctx.clearRect(0, 0, canvas.value.width, canvas.value.height);
    }
    pause.value = false;
  }
});

</script>

<style scoped lang="scss">

#settings {
  // on hover rotate the icon
  transform: rotate(0deg);
  transition: transform 0.5s;
  &:hover {
    transform: rotate(90deg);
  }

  &:active {
    transform: rotate(180deg);
  }
}

</style>
