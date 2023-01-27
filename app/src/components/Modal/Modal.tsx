import "./Modal.scss";

const Modal = ({ title, isOpen, onClose, children }) => {
  return (
    isOpen && (
      <div className="modal-overlay">
        <div className="modal-content">
          <div className="modal-title">
            <h4> {title} </h4>
            <div className="modal-close-button" onClick={onClose}>
              <svg
                width="14"
                height="14"
                viewBox="0 0 14 14"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M1 13L13 1"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                ></path>
                <path
                  d="M1 0.999999L13 13"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                ></path>
              </svg>
            </div>
          </div>
          {children}
        </div>
      </div>
    )
  );
};

export default Modal;
