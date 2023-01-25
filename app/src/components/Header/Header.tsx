import './Header.scss';
import whiteLogo from "../../assets/logo-white.png";
import { Link } from "react-router-dom";
import { ConnectKitButton } from 'connectkit';

function Header() {
    return (
        <header className="header">
            <Link to="/">
                <img className="header__logo" src={whiteLogo}></img>
            </Link>
            <nav className="header__nav">
                <Link to="/fund" style={{textDecoration: "none"}}>
                  <button className="header-create-fund-button">Your Fund</button>
                </Link>
            </nav>
            <ConnectKitButton />
        </header>
    );
}

export default Header;
