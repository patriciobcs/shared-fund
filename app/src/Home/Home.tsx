import "./Home.scss"
import Header from "../Header/Header";
import pie from "../assets/pie-example.png"
import {PieChart} from "react-minimal-pie-chart";


function Home(props){
    return (
        <div style={{backgroundColor:"#1c1c1c"}}>
            <Header/>
            <div className="home">
                <div className="home__title">
                    <h1> Fund3.0 </h1>
                    <h2> Your Decentralised Investment Fund </h2>
                </div>
                <div className="home__example">
                    <PieChart
                        data={[
                            { title: 'Bitcoin', value: 10, color: '#7f32a8' },
                            { title: 'Ethereum', value: 15, color: '#a832a4' },
                            { title: 'Chainlink', value: 20, color: '#f569f0' },
                        ]}
                        label={({ dataEntry }) => dataEntry.title }
                        labelStyle={(index) => ({
                            fontSize:'0.25rem',
                            fill:"white",
                        })}
                        paddingAngle={18}
                        rounded
                        radius={50}
                        labelPosition={60}
                        lineWidth={20}
                    />
                    <h3> 54 980 $</h3>
                </div>
            </div>
        </div>
    );
}

export default Home;