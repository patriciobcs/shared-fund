import "./Modal.scss"

const Modal = ({ title, isOpen, onClose, children }) => {
    return (
        isOpen && (
            <div className="modal-overlay">
                <div className="modal-content">
                    <div className="modal-title">
                        <h2> {title} </h2>
                        <button className="modal-button" onClick={onClose}>X</button>
                    </div>
                    <hr/>
                    {children}
                </div>
            </div>
        )
    );
};

export default Modal;