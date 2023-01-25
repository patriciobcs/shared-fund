import Modal from "../../Modal/Modal";
import React from "react";
import "./ConfirmModal.scss";

function ConfirmModal(props){
    return (
        <div>
            <Modal title={"Confirm"} isOpen={props.modalOpen} onClose={() => props.setOpen(false)}>
                <div className="confirm">
                    <label> Are you sure ? </label>
                    <div>
                        <button className="change" onClick={() =>  props.confirm}> Yes </button>
                        <button className="change" onClick={() => props.setOpen(false)}> No </button>
                    </div>
                </div>
            </Modal>
        </div>
    )
}


export default ConfirmModal