import React from 'react';
import './Header.scss';
import whiteLogo from "./../assets/logo-white.png";
import {Link} from "react-router-dom";

function Header() {
    return (
        <header className="header">
            <Link to="/">
                <img className="header__logo" src={whiteLogo}></img>
            </Link>
            <nav className="header__nav">
                <a href="#">About Us</a>
                <a href="#">Documentation</a>
                <button className="header__create-fund-button"><Link to="/fund">Your fund</Link> </button>
            </nav>
        </header>
    );
}

export default Header;
