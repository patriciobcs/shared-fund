import "./Header.scss";
import whiteLogo from "../../assets/logo-white.png";
import { Link } from "react-router-dom";
import { ConnectKitButton } from "connectkit";

function Header() {
  return (
    <header className="header">
      <Link to="/">
        <img className="header-logo" src={whiteLogo} alt="logo"></img>
      </Link>
      <div className="header-menu">
        <nav className="header__nav">
          <Link to="/fund" style={{ textDecoration: "none" }}>
            <button className="main-button">Your Fund</button>
          </Link>
        </nav>
        <ConnectKitButton />
      </div>
    </header>
  );
}

export default Header;
