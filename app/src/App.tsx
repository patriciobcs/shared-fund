import React from 'react';
import Home from "./components/Home/Home";
import SharedFund from "./components/SharedFund/SharedFund";
import {BrowserRouter, Routes, Route} from "react-router-dom";

function App() {
  return (
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Home/>}/>
          <Route path="/fund" element={<SharedFund/>}/>
        </Routes>
      </BrowserRouter>
      //<Home/>
  );
}

export default App;
