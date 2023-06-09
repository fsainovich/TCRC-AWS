const output = document.querySelector(".counter");

URL="https://cs3o44ahafbfrb3clp2n6k7k4i0joqrj.lambda-url.us-east-1.on.aws/"

async function views() {
        let response = await fetch(URL);
        let data = await response.json();        
        output.innerText = "V1 - This page got " + data + " views.";        
}

views();
