import { initializeApp } from 'firebase/app';
import { getAuth, onAuthStateChanged } from 'firebase/auth';
import { getDatabase } from 'firebase/database';

const firebaseApp = initializeApp({
    apiKey: "AIzaSyAb_8LRJC7j_8Q56pGhBc1AXfuYA6rgFdo",
    authDomain: "alertsafety-f7808.firebaseapp.com",
    databaseURL: "https://alertsafety-f7808-default-rtdb.firebaseio.com",
    projectId: "alertsafety-f7808",
    storageBucket: "alertsafety-f7808.appspot.com",
    messagingSenderId: "1021502003286",
    appId: "1:1021502003286:web:d011366cf698ab630c83f7",
    measurementId: "G-DBG87NRKQ9"
});

const auth = getAuth(firebaseApp);
const db = getDatabase(firebaseApp);

onAuthStateChanged(auth , user => {
    if (user != null){
        console.log('logged in ');
    }else{
        console.log('No User');
    }
});

